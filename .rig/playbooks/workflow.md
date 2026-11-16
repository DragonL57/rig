# Workflow

Use this playbook to plan, delegate, and close implementation. The main agent plans and orchestrates. It writes a change that fits one file and 30 lines itself. Every delegated change goes to an `implementer` and gets a reviewer.

Treat the steps as a checklist. When you skip a step, say why in one line of your reply.

## Roles

The specialists `implementer`, `taste-reviewer`, `spec-reviewer`, `docs-reviewer`, `test-reviewer`, `final-reviewer`, and `fallback-runner` are defined in the harness's agent directories. The implementer is the only editing role; reviewers inspect and report. Each specialist runs the model in its agent definition, or the session model when it names none; give `fallback-runner` an explicit model different from the writer's. On a harness without subagents, apply the roles through separate sessions or one agent adopting each role; when delegation is unavailable, name the spawn that failed, then do the work yourself against the same definition and say so.

## Steps

1. **Write the plan.** Where the repository has `backlog/`, reuse an open task that covers the work or create one with `backlog task create "<title>" --plain`, then record the plan with `backlog task edit <id> --plan "<steps>"` and the acceptance criteria with `--ac`. When the work splits into slices, the plan lists each slice's files and states that no shared registry, key, migration number, branch, generated artifact, or test helper crosses them, following `.rig/playbooks/parallel.md`. Use grilling when the user asks or when an unresolved product choice that belongs to the user blocks the plan.
2. **Review the plan.** Send the plan to `spec-reviewer` before any code exists, and to `taste-reviewer` when the shape is a product choice the user will see. Set the budget from `.rig/playbooks/review.md` step 3. Fix what they find, and tell the user what you rejected and why.
3. **Get the user's approval.** Build nothing before the user approves the reviewed plan.
4. **Write the invariants as failing tests** for shipping code, following `.rig/playbooks/testing.md`.
5. **Hand off to the implementer** for a delegated change. The failing tests are the verified first edit that proves the approach. Give it the approved plan; a map of the relevant files and what matters in each; rejected approaches and why; the landed first edit and its verification; the remaining steps and their checks. Disjoint slices go to parallel implementers in the same checkout, following `.rig/playbooks/parallel.md`; the brief names the slice's files and the rule that its check covers only those, reporting a failure outside them instead of editing it. The parallel path runs no git command. The implementer stops and reports when the handoff contradicts the real code.
6. **Review** a delegated change once near the end of a logical slice with `.rig/playbooks/review.md`. A change is a branch against its base, a range of commits on the default branch, or the working diff. Parallel work takes one integration pass after the slices land instead of a review per slice.
7. **Verify and stop.** Read the diff, run proportionate checks, and trace the affected path when needed. Once current criteria and checks pass, remove dispensable work and stop.
8. **Hand off the session state** where the next session will find it: the task notes, plus the handoff this harness provides. Do this once a delegated change is verified.
9. **Commit once.** After the spec is done and reviewed, make the single commit, or a `/pistate snapshot`, on the user's go-ahead.
