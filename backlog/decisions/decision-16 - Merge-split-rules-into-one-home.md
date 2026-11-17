---
id: decision-16
title: Merge split rules into one home
date: '2026-11-17T04:57:00Z'
status: accepted
---
## Context

The global `AGENTS.md` reached 450 lines, 4,420 words, 27,412 bytes, about 6,800 tokens, and it loads on every request in every project. Two blog posts the user supplied argued for a much smaller file on instruction-budget grounds. The primary sources in the `instruction-craft` skill do not support that argument:

- Size does not affect compliance. 1,650 sessions, files from 25 to 500 lines, instruction position, file architecture, and a contradicting secondary file all produced no detectable compliance effect (McMillan, arXiv:2605.10039).
- Polarity does affect compliance. Every individually beneficial rule was a negative constraint, every individually harmful one a positive directive (Zhang et al., arXiv:2604.11088). The file carried 57 negative constraints.
- A context file costs tokens without buying success. Context files add 20% or more to inference cost for no measurable task success (Gloaguen et al., arXiv:2602.11988).
- Compliance decays inside a session. Each function the agent writes lowers compliance odds by about 5.6%, so a rule that must hold across a long session needs repeating (McMillan, arXiv:2605.10039).

Volume was therefore the wrong target. The real defect was 138 lines of workflow rules living in two files. Each copy held part of a rule; neither held all of it, which is why they diverged. Every defect fixed in the session that produced this record came from that mechanism: a stale third copy under `.rig/playbooks/`, a `substantial` threshold left in eight files after it left one, a hardcoded endpoint, a report line the contract and the test disagreed about.

This supersedes the volume framing in `decision-6` for the global file. `decision-6`'s method, benchmark before and after, still applies to the kit's core contract.

## Decision

Merge each split rule into one home, and put the workflow rules in the playbook that loads when the work happens. Migrate first, cut second: nothing leaves the contract until its destination holds it.

- `## Phases` falls from 28 lines to 6. The six phase names now have one home, which the skip rule and the `phase` column of the decision trail read. Each phase is paired with the artifact that ends it, so "when a phase ends" resolves.
- `# Workflow` bullet 1 falls from 12 lines to 3, pointing at `workflow.md` step 1. Its four unique fragments moved into that step first: the 2+ steps threshold, the exit condition as `Done when: <command>`, read-only discovery being expected, and an autonomy grant satisfying the approval.
- `# Workflow` bullet 4 merged into `## Delegation`, which now carries all three strings the contract test greps.
- Four `## Delegation` bullets were removed; `review.md` steps 3 and 4 and `workflow.md` steps 4 and 5 already carried them.
- Five stranded fragments were placed rather than dropped: "search the codebase for the existing pattern" into the phase list, "capture is automatic, so do not hand-write routine notes" into the decision-trail bullet, "never conclude a verification attempt with a warning instead of a result" into the verification bullet, "do not explain code that is visible in the diff" into the response-style section, and "never sit through it" into `workflow.md` step 7.
- One fragment was dropped: "re-orient from the injected recall" has no mechanism anywhere in this install, so the Understand phase now carries it as a name only.

Three cuts were proposed and withdrawn:

- The Backlog block stays. `~/.pi/agent/AGENTS.md` is both the global contract and pi-state's project file, so for that working directory they are one path, and `AGENTS.override.md` would suppress the global content rather than add a project layer. `rig/install.sh` also re-appends the block whenever its marker is absent, and `core_only()` treats the marker as the end of the core. `decision-9` already records it as always-on content.
- The SLYE section stays whole. `speak-like-you-eat` registers `agent_end`, rewrites the finished message through a model, and runs only in TUI mode. It has no system-prompt hook, so it cannot touch READMEs, commit messages, PR descriptions, or code comments, all of which the section governs.
- Lazy senior dev mode stays whole. It is 16 bullets, 14 of them negative constraints, the class the evidence says helps. The first draft's proposed cut of four had no names and would have hit "do not refactor or reformat code unrelated to the task", the single strongest rule in that study.

## Consequences

The global contract is 405 lines, 3,943 words, 24,464 bytes, about 6,100 tokens, an 11% cut. That is the floor. The four strings the trim could reword, plus the rules with no other home, pin the rest. Anything below it loses a rule.

Each workflow rule now has one home, and the playbook that holds it loads before the first edit rather than on every request. The contract test greps each migrated string in its new home and fails when one leaves, so a rule that moves without its destination fails the suite. Re-duplication is guarded for the exit condition and unguarded for the rest.

Rejected: cutting to the 282 lines the first draft projected, which would have lost four rules.
