# Review

Use this playbook when you launch or brief reviewers and when you handle their findings. Reviewers inspect and report; you, the orchestrator, judge what to act on, and the plan's author defends the plan by default. Reviewers follow `.rig/playbooks/reviewing.md`.

Every step that applies runs. A delegated change takes the review step. Do not ask the user whether to review. A change whose review step did not run is reported as a defect in the run.

## Steps

1. **Choose the reviewers.** A plan gets its own review before the user approves it. A delegated change gets `spec-reviewer` and `taste-reviewer` once near the end of a logical slice. The single-file exemption in `AGENTS.md` (one file, 30 changed lines or fewer) owes neither reviewer, so A3's missing-reviewer finding does not apply to it. The orchestrator never reviews its own change in place of them. The bullets below add reviewers:
   - `test-reviewer` when behavior, tests, test infrastructure, or a shipping-code bug fix warrants evidence review;
   - `docs-reviewer` when a documented rule changed;
   - `uiux-reviewer` when the change adds or alters anything a user sees or operates: a screen, component, layout, style, interface copy, or a flow;
   - `final-reviewer` when the change as a whole (a branch against its base, a range of commits on the default branch, or the working diff) could fail end to end or change the decision to keep it;
   - `final-reviewer` and the user's own read when the change touches a path on the sensitive-path list in `HARNESS.md`;

   Run docs before final when both apply, and keep each reviewer to its role.
2. **Brief each reviewer** with the template below. The reviewer chooses its checks and judges independently.
3. **Set the budget** in the launch call: 12 turns for a plan review, 20 for ordinary reviews, 30 for interface review, 40 for final review, 8 for a correction check. The launch call wins, because no agent file pins `max_turns`. Lower budgets freely. For an increase, ask the user with a decision-changing question and the extra turns requested.
4. **Decide each finding.** Fix valid, in-scope, proportionate findings yourself on a change you write alone. Hand every other finding to the `implementer`. Reject a finding that is wrong, duplicated, out of scope, or disproportionate with a reason someone else can check against the code, the contract, or the evidence (for example "rejected: needs input above 65,535, which `parse.py:40` rejects"). Judge severity by the definitions in `reviewing.md` rather than the reviewer's heading, and say when you reclassify a finding. Ask the user only for a remaining product, scope, or risk choice. Bring every such choice, including each reviewer's user decision, to the user in one checkpoint with its options, and build none of them until the user chooses. Give every must-fix an explicit outcome, and get the user's acceptance before keeping the change with a valid must-fix unresolved. Keep report-only audits report-only until the user asks for changes.
5. **Check corrections locally.** After fixing findings, identify what changed and which findings or evidence it affects, and send only that delta to the reviewer it concerns, with the 8-turn budget passed explicitly in the launch call (on pi, `Agent(max_turns: 8, ...)`). Reopen settled or rejected findings only with new evidence. When two reviewers disagree on one finding, or the same finding returns twice, decide it only after one refutation from a reviewer on a different model. Run one full final review; repeat it only after a substantive change that invalidates it.
6. **Record the cost.** Append each review's `Turns` line, its wall-clock minutes, and any timed-out commands to the task notes. Record each finding's outcome beside them: fixed, waived, or wrong. These numbers let the user decide whether budgets or reviewers need to change; Rig sets no baseline.

## Brief template

```
Revision: <branch against its merge base, commit range on the default branch, or the working diff limited to the named paths>
Scope for this role: <what to judge; what belongs to other reviewers>
Task and specification: <IDs and paths>
Existing evidence: <checks already run and their results>
Settled findings: <findings already decided, with their outcome>
Open questions: <what you want answered>
Budget: <turns>
```

## When a reviewer cannot run

Use `fallback-runner` only when a reviewer cannot launch or complete because its provider, quota, session, or model is unavailable. Give it an explicit alternate model (omitting one silently inherits yours), the failed reviewer's agent definition verbatim, the `reviewing.md` playbook beside this one, and the brief. Pass the failed reviewer's turn budget explicitly in the launch call, since `fallback-runner` carries none of its own. Choose a model different from the writer's, and report every substitution to the user. The substitution is reported as a defect in the run, and the review still counts.

## Limits

Turn budgets and the timeouts in `reviewing.md` are experimental. A turn limit stops a reviewer that keeps taking turns; it leaves a long single command or an unproductive line of inquiry unbounded. How each editor enforces the limit is described in the specialist routing and bounded review specifications.
