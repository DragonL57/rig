# Parallel agents

Read this after `.rig/playbooks/workflow.md` steps 1 and 5, when the plan splits into slices that touch no shared file.

Give small or short-lived projects one implementer at a time. Run agents in parallel only when the time they save is longer than the time they cost to set up and merge.

## Foundations first, then parallel

The foundations are in the working tree before the parallel slices start: one agent owns the enum every slice touches, the state machine, and the shared constants. Then assign the remaining agents files that no other slice touches, including any shared test helper or fixture. When two agents would write the same file, branch, or key, split the target so each owns its part. Add coordination only when one shared writer is a real invariant.

Keep callers working when you change an API, so each slice starts from a tree that builds.

## One checkout, disjoint files

Every agent works in the same checkout. Nothing is committed until the work is done and reviewed, so a slice sees another slice's half-finished edits.

Three rules keep that safe:

- A slice never regenerates a shared artifact: a lockfile, codegen output, formatter output, or a snapshot. Hand install, codegen, format, and snapshot updates to one `implementer` after every slice lands.
- A slice's check covers its own files. A slice reports a failure outside its file set and leaves that file alone. The orchestrator re-runs that check after the neighbour lands.
- The orchestrator reads each slice with `git diff -- <its files>` and `git status --porcelain -- <its files>` before integrating, so a new file shows up too.

## Work no slice covers

Each agent can finish its slice and still leave a bug in work no slice covered: a constant that disagrees across two slices, documentation describing deleted behavior, or a stub that stops the feature working end to end. The orchestrator finds those gaps.

Name each agent's files in its slice, hand the leftovers to an `implementer`, and integrate: read each diff, run checks matched to each artifact's purpose, and trace one user path end to end. One integration pass covers the cross-slice contradictions that per-slice reviews cannot see, under `.rig/playbooks/review.md`.
