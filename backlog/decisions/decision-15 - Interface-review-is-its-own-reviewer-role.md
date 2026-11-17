---
id: decision-15
title: Interface review is its own reviewer role
date: '2026-11-17T03:17:00Z'
status: accepted
---
## Context

The agent kept introducing UI design inconsistency and bad UX planning. A fourth button style where three already existed, a spacing value no token produced, a form with no error state, a flow that asked the user for information before it showed them what they needed. None of the existing reviewers catches that class of defect.

`taste-reviewer` judges how the code is written. A component with three colour literals and no token passes it, because the code is tidy. `spec-reviewer` judges whether the change does what was asked, and the request rarely says "and no fourth button style". `final-reviewer` sees the change as one unit, which is the right altitude for composition and the wrong one for a 3.1:1 contrast ratio. Widening `taste-reviewer` to cover interface work would have made one reviewer answer two unrelated questions in one report, and the interface question would have lost to code quality every time, because that is the reviewer's name and its established habit.

## Decision

Interface and flow design is a seventh pinned specialist, `uiux-reviewer`, with its own role, its own budget, and a boundary against every other reviewer.

The repository is the first source of findings. A fourth button style, a spacing value no token produces, a missing error state, a colour outside the palette: those are read from the code and the tokens and need no external reference. They are also the defects a user actually hits. The HIG is the authority for what good looks like, cited by page and heading, and it is the second source rather than the first. That order is what keeps the role useful on a repository with no design system and honest on one with a bad one.

Without the `apple-design` skill the reviewer says the HIG is unavailable, marks every HIG-dependent judgment UNVERIFIED, and still reports what the repository shows. Refusing to review at all would have made the role dead on any machine without the skill, and the repository findings stand on their own.

The kit ships the 2 KB `browser-sessions` skill and vendors no copy of the HIG corpus. The corpus is about 1.5 MB across 123 pages and would need a refresh path in the kit; the skill is a claim rule that costs nothing to ship and that every agent driving a browser needs. The user installs the corpus with `npx skills add dickwu/apple-design-skill`, and the installer recap names that command, because a `--yes` run never reads the README.

The role runs in two modes. At plan time it judges the flow and whether the plan reuses the tokens and components already in the repository, opens no HIG page and no browser, and cites no HIG page. On a diff it does the full pass and measures in a browser. A flow that is wrong is cheaper to fix before the code exists.

Read-only holds by absence. The agent's `tools:` line names `read`, `bash` and `codemode` and no writer, so `harnesses.sh` gives opencode and Codex a read-only sandbox. Its `extensions:` line replaces the extension set with `pi-mcp-adapter` and `builtin:codemode`, which keeps the hashline editing tools out of the session and holds the spawn at about 7k tokens instead of about 30k. This is the only reviewer that keeps MCP, because it drives a browser.

## Consequences

- Seven pinned specialists and eight helpers in total. Every count in `harnesses.sh`, `install.sh`, `README.md` and the test suite moves with it.
- Interface review takes 30 turns rather than the ordinary 20, because the pass loads about 28 KB of skill, opens three to six HIG pages, and drives a browser. The number lives in `review.md` step 3 and in `doc-3`.
- `models.sh` `read_saved_models()` carries a hand-synced `AGENTS` whitelist beside `pinned_agents()`. Adding a role means adding it in both places, and the second one fails silently: a saved assignment for an unlisted role is dropped on read and overwritten on the next install. The test suite now asserts a saved `uiux-reviewer` entry survives a re-run, so the next role to hit this fails loudly instead of quietly.
- A reviewer that measures in a browser can report a number the orchestrator cannot reproduce without the same page. The Role field is what makes the finding checkable: it names the HIG page, the token or component the change breaks, or the flow step.
- The `apple-design` skill is a prerequisite outside the kit. An installation without it produces a working reviewer with HIG-dependent judgments marked UNVERIFIED, and no test can prove the difference; only a recorded spawn can.
