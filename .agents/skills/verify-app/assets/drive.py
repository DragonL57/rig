#!/usr/bin/env python3
"""Drive one feature from verify/features.tsv and report a measured result.

Exit 0 reached and passed, 1 reached and failed, 2 unreachable.
"""
import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.request

BROWSER_CMD = ["google-chrome-stable", "--headless=new", "--remote-debugging-port=0"]


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--feature", required=True, help="row name in verify/features.tsv")
    parser.add_argument("--base-url", default="http://localhost:3000")
    parser.add_argument("--map", default="verify/features.tsv")
    parser.add_argument("--out", default="verify/out")
    parser.add_argument("--timeout", type=float, default=30.0)
    return parser.parse_args()


def read_row(path, name):
    with open(path) as f:
        for line in f:
            line = line.rstrip("\n")
            if not line or line.startswith("#") or line.startswith("name\t"):
                continue
            fields = line.split("\t")
            if len(fields) != 4:
                raise SystemExit("bad row, expected 4 tab-separated fields: %r" % line)
            if fields[0] == name:
                return dict(zip(("name", "path", "ready_selector", "check"), fields))
    raise SystemExit("no row named %r in %s" % (name, path))


def browser_binary():
    for candidate in (BROWSER_CMD[0], "chromium", "google-chrome", "google-chrome-stable",
                      "chrome", "chromium-browser"):
        found = shutil.which(candidate)
        if found:
            return [found] + BROWSER_CMD[1:]
    raise SystemExit("no chromium or chrome on PATH")


def launch_browser(profile):
    cmd = browser_binary() + ["--user-data-dir=" + profile, "about:blank"]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    deadline = time.time() + 20
    while time.time() < deadline:
        line = proc.stdout.readline()
        if not line:
            if proc.poll() is not None:
                raise SystemExit("browser exited before printing a devtools endpoint")
            continue
        if "DevTools listening on" in line:
            return proc, line.split("DevTools listening on", 1)[1].strip()
    proc.kill()
    raise SystemExit("browser printed no devtools endpoint within 20s")


def page_ws_url(devtools_url):
    """The browser endpoint accepts no Page domain; a page target does."""
    base = devtools_url.split("/devtools/browser/")[0].replace("ws://", "http://")
    deadline = time.time() + 15
    while time.time() < deadline:
        try:
            with urllib.request.urlopen(base + "/json/list", timeout=5) as reply:
                targets = json.load(reply)
        except Exception:
            time.sleep(0.3)
            continue
        for target in targets:
            if target.get("type") == "page" and target.get("webSocketDebuggerUrl"):
                return target["webSocketDebuggerUrl"]
        time.sleep(0.3)
    raise SystemExit("no page target appeared on the devtools endpoint")


def cdp_connect(ws_url):
    try:
        from websocket import create_connection
    except ImportError:
        raise SystemExit("python websocket-client is missing: pip install websocket-client")
    return create_connection(ws_url, timeout=30)


def send(ws, method, params=None, msg_id=[0]):
    msg_id[0] += 1
    ws.send(json.dumps({"id": msg_id[0], "method": method, "params": params or {}}))
    while True:
        reply = json.loads(ws.recv())
        if reply.get("id") == msg_id[0]:
            if "error" in reply:
                raise RuntimeError("%s: %s" % (method, reply["error"]))
            return reply.get("result", {})


def evaluate(ws, expression):
    result = send(ws, "Runtime.evaluate", {
        "expression": expression,
        "returnByValue": True,
        "awaitPromise": True,
    })
    return result.get("result", {}).get("value")


def check_expression(check, selector):
    quoted = json.dumps(selector)
    if check.startswith("text:"):
        want = check.split(":", 1)[1]
        return "document.body.innerText.includes(%s)" % json.dumps(want)
    if check.startswith("count>="):
        want = int(check.split(">=", 1)[1])
        return "document.querySelectorAll(%s).length >= %d" % (quoted, want)
    if check.startswith("perf:"):
        body = check.split(":", 1)[1]
        metric, bound = body.split("<", 1)
        return "(performance.getEntriesByType('navigation')[0]||{})[%s] < %s" % (
            json.dumps(metric), bound)
    if check.startswith("attr:"):
        body = check.split(":", 1)[1]
        target, expected = body.split("=", 1)
        attr_selector, attr_name = target.rsplit("@", 1)
        return "!!document.querySelector(%s) && document.querySelector(%s).getAttribute(%s) === %s" % (
            json.dumps(attr_selector), json.dumps(attr_selector),
            json.dumps(attr_name), json.dumps(expected))
    raise SystemExit("unknown check %r" % check)


def capture(ws, out_path):
    shot = send(ws, "Page.captureScreenshot", {"format": "png"})
    import base64
    with open(out_path, "wb") as f:
        f.write(base64.b64decode(shot["data"]))


def main():
    args = parse_args()
    row = read_row(args.map, args.feature)
    url = args.base_url.rstrip("/") + row["path"]
    os.makedirs(args.out, exist_ok=True)
    profile = tempfile.mkdtemp(prefix="verify-app-")
    proc, ws_url = launch_browser(profile)
    result = {"feature": row["name"], "url": url, "check": row["check"],
              "reached": False, "passed": False, "value": None,
              "screenshot": None, "error": None}
    try:
        ws = cdp_connect(page_ws_url(ws_url))
        for domain in ("Page", "Runtime"):
            send(ws, domain + ".enable")
        send(ws, "Page.navigate", {"url": url})
        deadline = time.time() + args.timeout
        while time.time() < deadline:
            if evaluate(ws, "document.readyState") == "complete":
                break
            time.sleep(0.2)
        reached = evaluate(ws, "!!document.querySelector(%s)" % json.dumps(row["ready_selector"]))
        result["reached"] = bool(reached)
        if result["reached"]:
            result["value"] = evaluate(ws, check_expression(row["check"], row["ready_selector"]))
            result["passed"] = bool(result["value"])
        shot = os.path.join(args.out, row["name"] + ".png")
        capture(ws, shot)
        result["screenshot"] = shot
    except Exception as exc:
        result["error"] = str(exc)
    finally:
        proc.terminate()
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()
        shutil.rmtree(profile, ignore_errors=True)
    print(json.dumps(result, indent=2))
    if result["error"] or not result["reached"]:
        return 2
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
