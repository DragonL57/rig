---
id: TASK-38
title: Make the review step mandatory and unskippable
status: In Progress
assignee: []
created_date: '2026-11-17T04:00:00Z'
updated_date: '2026-11-17T04:23:00Z'
labels: []
dependencies: []
ordinal: 45000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The playbooks licensed skipping a step by asking the run to explain it. That let a delegated change reach the report with no reviewer, presented as a choice. Remove the escape and assert its absence.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 AC1: workflow.md and review.md both carry "Every step that applies runs".
- [ ] #2 AC2: neither playbook carries "When you skip a step".
- [ ] #3 AC3: review.md step 1 forbids the orchestrator substituting its own review for the pair.
- [ ] #4 AC4: the host AGENTS.md says the orchestrator never asks the user whether to review.
- [ ] #5 AC5: the report format carries no "No reviewers" variant.
- [ ] #6 AC6: eleven assertions in tests/test_install.sh and three in tests/test_harness.sh, with the mutation proofs recorded in the task notes.
- [ ] #7 AC7: sync --check clean, test_install.sh PASS, test_harness.sh 0 failed.
- [ ] #8 AC8: this change is reviewed by spec, taste, docs and test reviewers before the report.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Remove every licence that let a delegated change reach the report with no reviewer.

1. `.rig/playbooks/workflow.md:5` — replace "Treat the steps as a checklist. When you skip a step, say why in one line of your reply." with "Run every step that applies. A delegated change always takes the review step. Do not ask the user whether to review. Do not report a change whose review step did not run."
2. `.rig/playbooks/workflow.md:9` — the Roles paragraph's no-subagent fallback ends "do the work yourself against the same definition and say so". Append "Report the missing spawn as a defect in the run; a self-review never discharges the review step for a delegated change."
3. `.rig/playbooks/review.md:5` — the same replacement as item 1, so both playbooks state one rule.
4. `.rig/playbooks/review.md` step 1 — after "A delegated change gets `spec-reviewer` and `taste-reviewer` once near the end of a logical slice.", add "The orchestrator never reviews its own change in place of them."
5. `.rig/playbooks/review.md` "When a reviewer cannot run" — append "A substitution is reported as a defect in the run and never discharges the review step."
6. `~/.pi/agent/AGENTS.md:66-67` — the single-file exemption reads "No implementer, no reviewer." Append "Report it as the single-file exemption."
7. `~/.pi/agent/AGENTS.md:68-76` — the Workflow delegation bullet gains "Both are mandatory." and the report format loses its "No reviewers" variant: the second example becomes "Written by: orchestrator, one file, 24 changed lines. Reviewers: none, single-file exemption."
8. `~/.pi/agent/AGENTS.md:160-165` — the Delegation bullet appends "Both are mandatory. The orchestrator never reviews its own change in place of them, and never asks the user whether to review."
9. `~/.pi/agent/HARNESS.md:21-27` — the open item "Kit work: scale the reviewer set by risk" says "none for wording". Rewrite it so risk scales only the reviewers added on top of the mandatory pair, and record that the wording licence is what let a nine-file delegated change reach the report unreviewed.
10. `rig/README.md:11,31` — "brings in independent reviewers when they add value" and "Reviews take an extra minute when the slice warrants them" read as optional. Make both unconditional.
11. `rig/tests/test_install.sh` — four assertions on the installed playbooks: both carry "Run every step that applies", neither carries "When you skip a step", and review.md carries "never reviews its own change". Each proven by a mutation on a `cp -a` copy.
12. `~/.pi/agent/tests/test_harness.sh` — three assertions beside the existing contract block at line 193: the contract carries "never asks the user whether to review" and "Both are mandatory", and carries no "No reviewers.". Each proven by a mutation on a `cp -a` copy.
13. Render with `sync.sh`, run both suites, read every changed line back.
14. Send the change to `spec-reviewer`, `taste-reviewer`, `docs-reviewer` (a documented rule changed) and `test-reviewer` (test infrastructure changed) at the 20-turn budget, and fix their findings before the report. The plan review does not count.

Decided, not asked: the rule lands in the host contract only. The kit's `AGENTS.md` governs work inside a target repository and has no Delegation section, so adding one there would create a second copy `sync.sh` does not render.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Mutation proofs

Each guard was shown red on a `cp -a` copy under `/tmp`, then the copy was deleted and `git status --porcelain` confirmed the real tree was untouched.

### tests/test_install.sh

| Mutation on the copy | Result |
|---|---|
| delete `A delegated change takes the review step.` from `.rig/playbooks/review.md` | `FAIL: review.md no longer says a delegated change takes the review step` |
| delete `is reported as a defect in the run` from `.rig/playbooks/workflow.md` | `FAIL: workflow.md no longer reports a change whose review step did not run as a defect in the run` |
| delete `and the review still counts` from `.rig/playbooks/review.md` | `FAIL: review.md no longer says a substituted review still counts` |
| delete `Do not ask the user whether to review.` from `.rig/playbooks/review.md` | `FAIL: review.md no longer forbids asking the user whether to review` |
| delete `The work you do yourself is not the review step` from `.rig/playbooks/workflow.md` | `FAIL: workflow.md no longer says work done in place of a reviewer is not the review step` |
| delete `Every step that applies runs` from `.rig/playbooks/review.md` | `FAIL: review.md no longer requires every step that applies` |
| delete `never reviews its own change` from `.rig/playbooks/review.md` | `FAIL: review.md no longer forbids the orchestrator reviewing its own change` |
| restore `When you skip a step, say why.` to `.rig/playbooks/workflow.md` | `FAIL: an installed playbook still lets the agent skip a step and say why in one line` — this guard was later deleted as low value, because it only caught a verbatim revert of a sentence that no longer exists |
| append the string to `review.md` only | red, proving the two-file negative guard was not reading the first file alone |
| put `~/.pi/agent` back into the shipped `verify-app` | red, proving the directory-wide grep covers more than `SKILL.md` |

### ~/.pi/agent/tests/test_harness.sh

| Mutation on the copy | Result |
|---|---|
| delete `never reviews its own change` from `AGENTS.md` | `FAIL: AGENTS.md lets the orchestrator review its own change` |
| delete only the line-72 `Both are mandatory.` | `FAIL: AGENTS.md no longer makes spec-reviewer and taste-reviewer mandatory` |
| delete the `spec-reviewer: not run, single-file exemption.` example line | `FAIL: AGENTS.md's single-file exemption line no longer names a reviewer and its verdict` |
| restore `No reviewers.` to the report format | `FAIL: AGENTS.md offers 'No reviewers.' as a report line again` |
| delete `never asks the user whether to review` | `FAIL: AGENTS.md lets the orchestrator ask the user whether to review` |
| recreate `.rig/playbooks` | `FAIL: .rig/playbooks exists; rig/install.sh recreates that stale third copy on every run` |

## Review rounds

Round 1, four reviewers on the whole working diff, all `changes needed`, 40 findings. Round 2 correction checks: spec clean, taste clean, test clean, docs changes needed. Round 3 fixed the docs must-fixes and the test reviewer's unguarded-sentence findings. Round 4 correction check on docs: one must-fix, this Notes section.

The findings that changed the design, not just the wording:

- `Every step is mandatory` was false. Steps 4, 8 and 9 are conditional, so the sentence became `Every step that applies runs`.
- The first substitution rule said a `fallback-runner` substitution "never discharges the review step", which combined with "do not report a change whose review step did not run" made a provider outage unreportable. It now says the substitution is reported as a defect and the review still counts.
- `~/.pi/agent/.rig/playbooks/` was a stale third copy still carrying the removed licence, and `AGENTS.md:60,70` routed to it. Deleted, repointed to `~/.pi/agent/rig/playbooks/`, and guarded, because `rig/install.sh` recreates it for every target.
- The host comment policy was a condensed port that had lost the bound "When the cause lies outside the current work, report it to the user", which without it contradicted "Do not grow the diff". Replaced with the kit's two bullets verbatim.
<!-- SECTION:NOTES:END -->
