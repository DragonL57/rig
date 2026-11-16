# Workflow

Use this playbook to plan, delegate, and close substantial implementation. The main agent plans and orchestrates; it implements small, short fixes directly and closes them with step 6.

Treat the steps as a checklist. When you skip a step, say why in one line of your reply.

## Roles

The specialists `implementer`, `taste-reviewer`, `spec-reviewer`, `docs-reviewer`, `test-reviewer`, `final-reviewer`, and `fallback-runner` are defined in the harness's agent directories. The implementer is the only editing role; reviewers inspect and report. Each specialist runs the model in its agent definition, or the session model when it names none; give `fallback-runner` an explicit model different from the writer's. On a harness without subagents, apply the roles through separate sessions or one agent adopting each role; when delegation is unavailable, do the work yourself against the same definition and say so.

## Steps

1. **Agree a bounded plan** with the user before substantial or unclear work. Use grilling when the user asks or when an unresolved product choice that belongs to the user blocks the slice.
2. **Sketch the shape** of new modules or cross-boundary interfaces with `.rig/playbooks/design.md`, and put the sketch in the plan.
3. **Write the invariants as failing tests** for shipping code, following `.rig/playbooks/testing.md`.
4. **Hand off to the implementer.** The sketch and failing tests are the verified first edit that proves the approach. Give it the approved plan; a map of the relevant files and what matters in each; rejected approaches and why; the landed first edit and its verification; the remaining steps and their checks. The implementer stops and reports when the handoff contradicts the real code.
5. **Review** substantial changes once near the end of a logical slice with `.rig/playbooks/review.md`. A change is a branch against its base or a range of commits on the default branch; either works.
6. **Verify and stop.** Read the diff, run proportionate checks, and trace the affected path when needed. Once current criteria and checks pass, remove dispensable work and stop.
7. **Hand off the session state** where the next session will find it: the task notes, plus the handoff this harness provides. Do this once a substantial implementation is verified.
