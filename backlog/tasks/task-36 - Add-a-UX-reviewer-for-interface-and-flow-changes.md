---
id: TASK-36
title: Add a UX reviewer for interface and flow changes
status: In Progress
assignee:
  - '@thelong'
created_date: '2026-11-17T02:22:00Z'
updated_date: '2026-11-17T03:27:00Z'
labels: []
dependencies: []
references:
  - doc-3 - Bounded-review-policy.md
  - skills/apple-design/SKILL.md
priority: high
type: enhancement
ordinal: 43000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The kit has no reviewer that owns what a user sees or operates. Taste owns how the code is written, spec owns whether the change does what was asked, test owns evidence, docs owns documentation, and final owns composition. Interface design falls between all five, so nothing catches it.

The symptom is a run that ships a screen with a fourth button style, a spacing value no token produces, a form with no error state, or a flow that asks the user to confirm before it has shown them what they are confirming. Each commit reviewed clean, because no reviewer was looking.

A separate role is the fix rather than widening taste-reviewer. Interface review needs a different reference set (the apple-design skill's 123 HIG pages), a different question (does this look and behave like the rest of the product, and does the flow make sense), and a plan-time pass, because a flow that is wrong is cheaper to fix before code exists than after.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A uiux-reviewer agent definition exists in agents/ and renders into the install through sync.sh
- [ ] #2 The rendered pi agent carries extensions: pi-mcp-adapter, builtin:codemode and no exclude_extensions line, so it reaches the chrome-devtools servers
- [ ] #3 The rendered pi agent has no replace and no write in its tool list, so read-only holds by absence rather than by instruction
- [ ] #4 The agent reports inconsistency against the repository's own tokens and components first, and uses the HIG as the authority for what good looks like
- [ ] #5 Without the apple-design skill the agent says the HIG is unavailable, marks HIG-dependent judgments UNVERIFIED, and still reports what the repository shows
- [ ] #6 The agent reads .agents/skills/browser-sessions/SKILL.md for the claim rule, and the kit ships that skill
- [ ] #7 At plan time the agent judges the flow and reuse of existing tokens, opens no HIG page and no browser, and cites no HIG page
- [ ] #8 On a diff the agent measures with evaluate_script, take_snapshot and list_network_requests, and cites a HIG page, a token, or a component per finding
- [ ] #9 models.sh lists uiux-reviewer in pinned_agents() and in the agent_preferences() review case, and LEGACY_ROLES is deliberately left alone
- [ ] #10 workflow.md step 2 names uiux-reviewer for a plan describing a new screen or flow, and review.md step 1 names it for a diff that alters what a user sees or operates
- [ ] #11 review.md and doc-3 carry 30 turns for interface review, and doc-3 names interface and flow design as a role
- [ ] #12 doc-4 names uiux-reviewer in its routing row and in the Claude Code clause
- [ ] #13 A decision record explains why interface review is its own role, why the repository is the first source of findings, and why the kit ships the browser skill but not the HIG corpus
- [ ] #14 Every count moves correctly: seven pinned specialists and eight helpers across harnesses.sh, install.sh, README.md and the test comments
- [ ] #15 README and the install prompt name npx skills add dickwu/apple-design-skill as the prerequisite, and the kit vendors none of the HIG corpus
- [ ] #16 A recorded spawn against a local fixture returned the measured contrast ratio and the off-palette hex, not a restatement
- [ ] #17 tests/test_install.sh defines the agent lists once and loops them, and both test suites pass
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Write `agents/uiux-reviewer.md` frontmatter. Use the shape the probe measured, not a guess: `tools: read, bash, codemode`, `extensions: pi-mcp-adapter, builtin:codemode`, `thinking: high`, and no `exclude_extensions` line. The tool list makes it read-only; the extensions line keeps it at 7.0k tokens instead of 30.3k. Verified: `write_pi_agent()` copies the file with `cp`, or with an `awk` that prints every line, so `extensions:` survives the render.

2. Write the body's finding rule. Report inconsistency against the repository first: a fourth button style where three exist, a spacing value no token produces, a form with no error state, a colour outside the palette. Those findings come from the code and need no external reference, and they are the defect the user actually hit. Use the HIG as the authority for what good looks like, and cite the page. When the skill is absent, say the HIG is unavailable, mark every HIG-dependent judgment UNVERIFIED, and still report what the repository shows. Never state a design rule the HIG does not state.

3. Write the body's HIG routing. Read `SKILL.md`, use its tables to open the three to six pages the change touches, then `references/code-audit.md` for what to search in source and `references/cross-platform.md` for Flutter, React Native, Tauri and Electron vocabulary. The skill lives at `~/.pi/agent/skills/apple-design/` on pi, `~/.claude/skills/apple-design/` on Claude Code, and `.agents/skills/apple-design/` in a project, so name the harness directory rather than one absolute path.

4. Write the body's browser procedure. Read `.agents/skills/browser-sessions/SKILL.md` for the claim rule. Measure rather than eyeball: `evaluate_script` for computed styles, geometry and contrast ratios, `take_snapshot` for the accessibility tree, `list_network_requests` for the calls behind the page. A screenshot is for the user, not for the reviewer's own verdict. On a harness without a browser, read the code and ask for a screenshot, and say which of the two it did.

5. Write the body's scope and the two modes. Scope: visual hierarchy, spacing and type scales, colour and contrast, dark mode, iconography, density, motion; control choice, every state (empty, loading, error, partial, disabled, success), feedback, navigation and back behaviour, focus order, touch targets, interface copy; reuse of existing tokens and components; and the flow. At plan time it judges the flow and whether the plan reuses the tokens and components already in the repo, opens no HIG page and no browser, and cites no HIG page. On a diff it does the full pass. Leaves code quality to `taste-reviewer`, requested behaviour to `spec-reviewer`, evidence to `test-reviewer`, documentation to `docs-reviewer`, composition to `final-reviewer`. Role field per finding: the HIG page, the token or component it breaks, or the flow step.

6. Ship the browser skill with the kit. Add `.agents/skills/browser-sessions/` (2 KB, already written at `~/.pi/agent/skills/browser-sessions/SKILL.md`) and add `browser-sessions` to the hard-coded list in `install.sh` `install_session_skills()` (line 601) and to the recap string at line 742. One copy in the kit, no drift, and every user gets the claim rule.

7. Register the role in `models.sh`. Add `uiux-reviewer` to the `pinned_agents()` printf (line 66, after `spec-reviewer`). Extend the `agent_preferences()` review case (lines 30-33) from `taste-reviewer|spec-reviewer` to `taste-reviewer|spec-reviewer|uiux-reviewer`, so it takes `gpt-6.1-terra medium` then `_routine_review_fallbacks`. Leave `LEGACY_ROLES["reviewer"]` at line 99 alone: a legacy role-keyed file predates this role, and silently assigning it would be a surprise. State that in the commit body.

8. Keep the other three harnesses valid. Add `codemode) ;;` to `claude_tools()` so an unknown name does not land in a Claude Code tools list. `agent_can_write()` already finds no writer in `read, bash, codemode`, so opencode and codex get their read-only sandbox with no change. Update the frontmatter comment at `harnesses.sh:7` to include `extensions` in pi's key list.

9. Move every count. One pinned agent added means seven pinned and eight helpers in total. Exact sites: `harnesses.sh:2` "seven agent definitions" becomes eight. `install.sh:302` "seven helpers" becomes eight. `install.sh:405` "six columns side by side" becomes seven. `install.sh:745-748` "six pinned specialists: implementer, taste-reviewer, spec-reviewer, docs-reviewer, test-reviewer, final-reviewer" becomes seven with `uiux-reviewer` in the list, and "the same seven" becomes eight in the three harness lines. `README.md:49` seven becomes eight. `README.md:56` "The six specialists" becomes seven, and the bullet list gains a `uiux-reviewer` entry. `README.md:68` names uiux review in the routing sentence. `README.md:97` seven becomes eight. `README.md:99` six becomes seven. `README.md:101` seven becomes eight. `README.md:97-101` prompt step 6 also names `npx skills add dickwu/apple-design-skill`, so an agent-driven install is not left without it. `test_install.sh:740` comment "All seven agents ship everywhere. The six specialists" becomes eight and seven.

10. Wire the plan-time trigger. `.rig/playbooks/workflow.md` line 9 lists the specialists and gains `uiux-reviewer`. Line 14, step 2, names it for a plan that describes a new screen or flow, at 12 turns, judged on the flow and on reuse of existing tokens, with no HIG page and no browser.

11. Wire the diff-time trigger and its budget. `.rig/playbooks/review.md` line 9 gains a conditional bullet: `uiux-reviewer` when the change adds or alters anything a user sees or operates, a screen, component, layout, style, interface copy, or a flow. Line 16 gains the number: 30 turns for interface review, because 28 KB of skill plus three to six pages plus a browser session does not fit in 20. `doc-3:24` gains the same number, and `doc-3:12` "Scope and roles" gains interface and flow design as a role, conditional the same way.

12. Update the routing spec. `doc-4:19` row label "taste / spec reviewer" becomes "taste / spec / uiux reviewer". `doc-4:24` adds uiux to the Claude Code clause that assigns `opus` high to taste, spec and docs review.

13. Record the decision. `backlog decision create` covering why interface review is its own role rather than a widened `taste-reviewer`, why the HIG is the reference and the repository is the first source of findings, why the kit ships the 2 KB browser skill but not the 1.5 MB HIG corpus, and why the role still reports without the HIG.

14. Save the assignment and fix the host record. Add `uiux-reviewer` to `~/.pi/agent/.rig/models.json` under `pi` with `mistral/deepseek-v4-1-flash-1017` at effort `high`, then render with `sync.sh`. The saved entry wins on this machine; the `models.sh` preference list is what a fresh install resolves. `~/.pi/agent/HARNESS.md:15` "The five reviewers" becomes six, and line 51's effort ladder gains uiux at `high`.

15. Extend `tests/test_install.sh`. Define the agent lists once at the top of the file (`agents_all=...`, `agents_pinned=...`) and loop them, instead of hand-syncing a name into twelve places. Add the model and effort assertion beside lines 154-165. Assert the rendered pi agent carries `extensions: pi-mcp-adapter, builtin:codemode`, has no `exclude_extensions` line, and has no `replace` or `write` in its tool list. Assert the rendered claude agent has no `codemode` in its tools list. Assert the body names `apple-design` and carries the UNVERIFIED fallback sentence. Update the two literal agent sets at 952 and 1011 to seven.

16. Verify on a fixture with a known answer. Build `/tmp/uiux-fixture/index.html`: three button styles plus a fourth using `#7c3aed` where the palette has `#4f46e5`, a 13px gap where the scale is 4, 8, 16, 24, a form with no error state, body text at 3.1:1 contrast, and a dialog with no focus trap. Serve it with `python3 -m http.server 8765`. Run the suite checks: `sync.sh --check` up to date, `tests/test_install.sh` PASS, `tests/test_harness.sh` 0 failed. Then one recorded spawn of `uiux-reviewer` briefed to review `http://localhost:8765/`: claim a free browser instance, navigate, snapshot, measure computed styles and contrast, and report. The spawn passes only if it reports the contrast ratio as a measured number and names the off-palette hex. A report that restates the markup, or misses both planted defects, fails this step. Delete the fixture afterwards.

Done when: `bash /home/thelong/rig/tests/test_install.sh` prints PASS, `bash /home/thelong/.pi/agent/tests/test_harness.sh` reports 0 failed, `bash /home/thelong/.pi/agent/rig/sync.sh --check` reports up to date, and the recorded spawn on the local fixture reported the measured contrast ratio and the off-palette hex.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Verification run

`uiux-reviewer` spawned against a local fixture at `http://localhost:8765/` (served by `python3 -m http.server`, deleted afterwards). The fixture carried five planted defects and a declared token palette, so the run had a known answer.

Planted and found:

| Planted | Reported |
|---|---|
| body text at about 3.1:1 contrast | `--color-muted` #929292 measures **3.11:1** on #ffffff and **2.91:1** on #f7f7f8 |
| a fourth button using #7c3aed where the palette has #4f46e5 | "background #7c3aed (no token produces it), `border-radius: 3px` against `--radius: 6px`, `padding: 11px 19px` against `--space-2`/`--space-3`; measured heights 41.2 / 36.8 / 35.2 / 27.2 px" |
| a 13px gap where the scale is 4/8/16/24 | "`.row` uses `gap: 13px`, which no token produces (`--space-2` 8px, `--space-3` 16px); measured gaps 13/13/13 px" |
| a form with no error state | "submitting the form produces 0 `[aria-live]`/`[role=status]`/`[role=alert]` nodes, no text change, and the input keeps its value" |
| a dialog with no focus trap | the dialog was measured as correct (Escape closes, focus trapped, focus returns), and the run instead found the dialog has no accessible name |

Also found and not planted: `prefers-color-scheme: dark` reported true with 0 `@media` rules in the stylesheet; `#confirm` has no listener so the delete flow has no final step; four row buttons are `type="submit"` with no form; the destructive action carries the primary style; `h2` at 15px is smaller than the 16px controls it heads; the input border measures 1.27:1; no `:focus-visible` rule, with the keyboard ring at 1.72:1.

Every finding carried a Role field naming a HIG page and heading, a token, or a flow step. The report cites `accessibility.md`, `dark-mode.md`, `color.md`, `buttons.md`, `text-fields.md`, `typography.md`, `layout.md`, `alerts.md`, `writing.md` and `feedback.md`.

Turns: 10 of 20. No timed-out commands.

## Reviewer rounds

Round 1, four reviewers at 20 turns each, all `changes needed`, 24 findings. Two were convergent and demonstrated:

- `models.sh` `read_saved_models()` kept a hand-synced `AGENTS` whitelist of six agents, so a saved `uiux-reviewer` assignment was dropped on read and overwritten on the next install. Both `spec-reviewer` and `docs-reviewer` proved it with a probe.
- The decision record AC#13 requires did not exist. Created as `decision-15`.

Round 1 also produced: the read-only assertion missed `insert` (mutation stayed green); `agents_all` was a hand-maintained third copy, so an eighth agent shipped unchecked (mutation stayed green); the `exclude_extensions` grep was whole-file and false-positived on a body reflow; two assertions failed silently under `set -e`; `AGENTS.md`'s playbook index never mentioned `browser-sessions`; `.agents/skills/rig-update/SKILL.md` told the updating agent to check seven helpers and six specialists; the agent body was a 97-line, eight-heading outlier among 12-28 line siblings with three rules stated twice and no read-only sentence; and its `browser-sessions` path was hard-coded to `.agents/skills/`, which does not exist on pi.

## Spawn report, verbatim

Verdict: changes needed.

must-fix:

- `index.html:11,75,76` | demonstrated defect | `--color-muted` #929292 renders at 14px and measures **3.11:1** on `--color-bg` #ffffff and **2.91:1** on `--color-surface` #f7f7f8; it carries both `p.body-copy` paragraphs and the `span.label` "This cannot be undone.", so the destructive warning is the lowest-contrast text on the page | move `--color-muted` to #6b6b6b (5.33:1 on white) and keep the warning at body weight | `accessibility.md › "Strive to meet color contrast minimum standards"` (table: text up to 17 pt, all weights, 4.5:1)
- `index.html:7-20,92` | demonstrated defect | the browser reports `matchMedia('(prefers-color-scheme: dark)')` = **true**, and the page still renders `body` background rgb(255,255,255) with text rgb(26,26,26) and dialog background rgb(255,255,255); computed `color-scheme` is `normal` and the stylesheet contains **0** `@media` rules, so no color token has a dark variant | add `color-scheme: light dark` and a `prefers-color-scheme: dark` block that redefines the seven color tokens | `dark-mode.md › "Ensure that your app looks good in both appearance modes"`; `color.md` (line 20: supply light and dark variants for every custom color)
- `index.html:130` | demonstrated defect | the dialog's confirm button `#confirm` has no listener; `document.getElementById('confirm').click()` leaves `dialog.open === true` with no text or state change, so the delete flow has no working final step | wire `#confirm` to close the dialog and report the outcome, or remove the button until the action exists | flow step 3 of the delete flow; `feedback.md › "When it makes sense, confirm that a significant action or task has completed"`
- `index.html:101-104` | demonstrated defect | "Save changes", "Cancel", "Learn more" and "Invite teammate" are `type="submit"` with `form === null` and no handler, so a click or Enter does nothing; `#open-delete` at line 120 is the only row button with a listener | give each button its action, or render the ones with no action as disabled with a reason | flow step 1 (Members); `feedback.md` (line 30)
- `index.html:112-113` | demonstrated defect | submitting the form produces **0** `[aria-live]`/`[role=status]`/`[role=alert]` nodes, no text change, and the input keeps its value; there is no error state for a malformed address and no success state for a good one | add a status region next to the field that reports invalid and subscribed | flow step 2 (Notifications); `feedback.md` (line 30); `writing.md` (line 46: write errors close to the problem)
- `index.html:125` | demonstrated defect | the accessibility tree shows `dialog modal` with **no accessible name**; `aria-label` and `aria-labelledby` are both null and the `h2` inside does not name it | add `aria-labelledby` pointing at the dialog's `h2` | `accessibility.md › "Describe your app's interface and content for VoiceOver"`
- `index.html:129-130` | demonstrated defect | the destructive action is `btn-primary` (rgb(79,70,229)) and the safe action is `btn-secondary`, so the irreversible choice is the prominent one; the palette also has no destructive color to use | give "Delete" a destructive style from a new `--color-danger` token and keep the safe action plain | `buttons.md › Style`: "Don't assign the primary role to a button that performs a destructive action, even if that action is the most likely choice"
- `index.html:64-72` | demonstrated defect | a fourth button style exists beside the three the stylesheet names: background #7c3aed (no token produces it), `border-radius: 3px` against `--radius: 6px`, `padding: 11px 19px` against `--space-2`/`--space-3`; measured heights in one row are **41.2 / 36.8 / 35.2 / 27.2 px** and two different indigos (#4f46e5, #7c3aed) both read as primary | delete `.btn-invite` and use `btn-primary` with `--radius` and `--space-2`/`--space-3` | `--radius` and `--space-*` tokens; `buttons.md › Style`: "Use style — not size — to visually distinguish the preferred choice"
- `index.html:110-113` | demonstrated defect | the section says "Choose which updates reach your inbox" and offers no choice: the only controls are a single email input and "Subscribe", so the section's stated job has no control behind it | add the notification toggles, or rewrite the heading and copy to describe an email subscription | flow step 2 (Notifications); `writing.md` (line 50: describe what the setting does)

minor:

- `index.html:31` | `h2` is 15px while the button labels under it are 16px and the body default is 16px, so each section heading is smaller than the controls it heads | `typography.md › "Conveying hierarchy"`
- `index.html:74` | `.row` uses `gap: 13px`, which no token produces (`--space-2` 8px, `--space-3` 16px); measured gaps between the four buttons are 13/13/13 px | `--space-2`/`--space-3` tokens; `layout.md › "Visual hierarchy"`
- `index.html:79-84` | the email input's only boundary is a 0.8px #e4e4e7 border measuring **1.27:1** against white and 1.19:1 against the surface; `.btn-secondary` uses the same 1.27:1 border | my judgment against WCAG 1.4.11; the HIG gives no non-text ratio
- `index.html:112` | the field has `aria-label` but no visible label, so its purpose disappears the moment the user types | `text-fields.md › Best practices` (line 16)
- `index.html:7-20` | no author `:focus-visible` rule exists; the keyboard ring measures `auto 0.8px rgb(168,199,250)`, **1.72:1** on white and 3.31:1 on the #7c3aed button | my judgment against WCAG 2.4.11; `accessibility.md`
- `index.html:129` | the cancel action is labelled "Keep it", and one action carries three names across the flow: "Delete workspace" (line 120), "Delete this workspace?" (line 126), "Delete" (line 130) | `alerts.md` (line 58) plus `writing.md` (line 36)
- `index.html:120` | "Delete workspace" is `btn-secondary`, visually identical to "Cancel" at line 102, so the same grey means "safe" in one section and "destroys every project, task and comment" in another | my judgment; `buttons.md › Role`
- `index.html:58` | "Learn more" measures 27.2px tall, under the 28px default control size for desktop | `accessibility.md › "Offer sufficiently sized controls"`
- `favicon.ico` | the page's second and last network request returns **404** | none

Good: the native `<dialog>` does the hard parts: Escape closes it, focus is trapped inside, the tab order is Keep it → Delete, and focus returns to `#open-delete` after Escape (measured `document.activeElement.id === "open-delete"`). Button labels pass contrast comfortably (6.29:1 primary, 5.70:1 invite, 16.26:1 secondary), the tab order follows visual order across all six stops, and the page makes two static requests with no async work behind any control.

Coverage: computed styles, geometry and contrast for 17 elements at 1536x722, dpr 1.25, ratios computed from the browser's own rgb values; keyboard tab order over 6 stops with `:focus-visible` and outline readings; dialog open, Escape, focus restore and a click on `#confirm`; form submit with a valid address; `take_snapshot` accessibility tree with the dialog open; `list_network_requests` (2 requests, one 404); a scan of every stylesheet rule for `@media`, `:focus`, `transition` and `animation` (0 matches); the `:root` custom properties read back from the live page. Unverified: no 200% text-zoom or reflow pass, no mobile viewport pass, no Lighthouse run, no screen-reader session beyond the accessibility tree, and no forced-colors or increased-contrast emulation. Turns: 10 of 20.

## Round 2, correction checks

spec-reviewer: clean. docs-reviewer: clean. test-reviewer: clean. taste-reviewer: changes needed, one must-fix, which was a regression this orchestrator introduced when it told an implementer to delete the plan-time HIG clause; restored, and the taste reviewer's two minors were fixed with it. Six minors from round 2 were also fixed: `doc-4` now names `uiux-reviewer` in its Agent cell and its Claude Code clause; the `apple-design` line moved out of the "What you now have" list into a prerequisite note; `install.sh` derives the skills list from `.agents/skills/*/` instead of a hand-synced literal; the decision record states one rounded token baseline; the spawn report is pasted above; and `codemode` is now allowed only for `uiux-reviewer` in the test allowlist, proven by a mutation that puts it in `docs-reviewer` and goes red.
<!-- SECTION:NOTES:END -->
