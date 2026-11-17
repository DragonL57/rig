---
name: browser-sessions
description: Claim a free Chrome DevTools MCP instance and drive a real browser page. Use when a task needs a browser, a rendered page, a check of computed styles, geometry, contrast, DOM state or network calls, or a screenshot the user asked for.
---

# Browser sessions (chrome-devtools MCP)

## Claim an instance

Run this before the first browser call:

```bash
for p in pi-1 pi-2 pi-3; do
  if pgrep -f "[c]hrome .*--user-data-dir=$HOME/.cache/chrome-devtools-mcp/$p( |$)" >/dev/null; then echo "$p busy"; else echo "$p free"; fi
done
```

Instances: `chrome-devtools` -> `pi-1` (`chrome_devtools_*`), `chrome-devtools-2` -> `pi-2` (`chrome_devtools_2_*`), `chrome-devtools-3` -> `pi-3` (`chrome_devtools_3_*`).

## Do not

- Do not reuse an instance whose profile already has a live Chrome: the second server joins that process and both sessions drive the same tabs. Claim the first free instance.
- Do not close, navigate, or reuse a page another session opened.
- Do not run parallel Pi sessions on one instance; one instance per session.
- Do not treat a `chrome-devtools-mcp` server process as a busy profile. Another tool, or an idle session, can hold a server on the same user-data-dir with no browser running. Match the Chrome browser binary, which is the process that actually collides.
- Do not point Pi at the Command Code profiles (`chrome-profile`, `cc-2`, `cc-3`) or the Claude profiles (`claude-1` to `claude-3`); those belong to those tools.
- Do not verify a rendered UI with a Playwright script, and do not take a screenshot to check your own work. Load the chrome-devtools MCP and drive the real page: `evaluate_script` for computed styles, geometry, contrast and DOM state, `list_network_requests` for the calls behind it. A screenshot is for the user to look at when they ask.
- Do not keep a second browser driver in a repo. A headless script earns its place only when it is a repeatable numeric gate that runs without a person, and then it measures computed values rather than pixels.
