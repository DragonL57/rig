---
name: verify-app
description: Give a reviewer a screenshot and a measured check instead of a diff. Use when a change touches a feature in the target app's feature map, when the user asks whether something works in the running app, or when a delegated change needs runtime evidence.
---

# Runtime verification

A reviewer reading a diff can only judge what the code says. This skill produces the other kind of evidence: the app running, the feature reached, and a value measured from the real page.

Two artifacts, both project-local:

- **The feature map**, `verify/features.tsv`, one row per user-visible feature: the name a person would say, the URL or command that reaches it, the selector that proves it is there, and the check that proves it works.
- **The driver**, `verify/drive.py`, which turns one row into a JSON result: reached, measured, screenshot path.

The map is the shared vocabulary: "The thingy in the left sidebar" resolves to a row, so a reviewer and the implementer name the same feature.

## Steps

1. **Find or create the map.** Look for `verify/features.tsv` in the target repository. When it is absent, create it from the template below with the features the change touches, not the whole app. A map with three real rows beats one with thirty guesses.
2. **Run the driver against the changed feature.**
   ```bash
   python3 verify/drive.py --feature "<name>" --base-url http://localhost:3000
   ```
   It exits 0 when the feature was reached and its check passed, 1 when it was reached and failed, and 2 when it could not be reached.
3. **Attach the result to the reviewer brief** under `Existing evidence:`, with the screenshot path. The reviewer judges the artifact; it does not re-drive the app.
4. **Add a row when the change adds a feature.** A feature with no row cannot be verified, so the row is part of the change, not follow-up work.

## The map format

Tab-separated, one header row, comments with `#`:

```
name	path	ready_selector	check
chat-compose	/chat	[data-testid=composer]	text:Send
settings-models	/settings/models	[data-testid=model-list]	count>=1
launch-time	/	[data-testid=app-root]	perf:domContentLoaded<2500
```

`check` is one of:

- `text:<string>`: the page contains this text.
- `count>=<n>`: the selector matches at least n elements.
- `perf:<metric><<ms>`: a Performance API metric is under the bound, which is the startup-time case.
- `attr:<selector>@<name>=<value>`: an attribute holds a value.

Anything the driver cannot express belongs in a project test, not in this file. The map stays small enough to read.

## The driver

Copy `verify/drive.py` from this skill's `assets/` into the repository, then edit only `BROWSER_CMD` if the project's browser differs. It uses the Chrome DevTools Protocol over a websocket, so it needs no Playwright dependency and no second browser stack in the repo.

```bash
mkdir -p verify && cp <this-skill-directory>/assets/drive.py verify/drive.py
printf '# name\tpath\tready_selector\tcheck\n' > verify/features.tsv
```

## Do not

- Do not verify a rendered UI with a Playwright script when `browser-sessions` can drive the real page. The driver here exists for the repeatable gate a reviewer runs without a person, and it measures computed values rather than pixels.
- Do not take a screenshot to check your own work. The screenshot is the artifact the reviewer and the user look at.
- Do not put a feature in the map that the driver cannot reach without seeding data. Seed it in the driver's `--seed` hook instead, so the check stays one command.
- Do not let the map drift from the app. A row whose selector no longer matches is a broken check, and the driver reports it as exit 2 rather than a pass.

## When the app cannot run here

Say so in one line and fall back to the diff-only review. A verification skill that silently passes on an app it never reached is worse than no skill, which is why exit 2 is distinct from exit 1.
