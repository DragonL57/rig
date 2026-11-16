---
id: TASK-33
title: Write the plan, review it, and get approval before implementation
status: To Do
assignee: []
created_date: '2026-11-16T04:37:00Z'
updated_date: '2026-11-16T05:03:00Z'
labels: []
dependencies: []
ordinal: 40000
---

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The workflow playbook creates the task and writes the plan before any code exists
- [x] #2 The plan goes to a reviewer before the user sees it for approval
- [x] #3 The user approves the reviewed plan before the first edit
- [x] #4 AGENTS.md gates on the written plan and the Tier 0 execute line no longer outranks it
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create this task with its acceptance criteria, and record the plan in it.
2. Rewrite `.rig/playbooks/workflow.md` as eight steps: write the plan, review the plan, get the user's approval, write the invariants as failing tests, hand off to the implementer, review, verify and stop, hand off the session state. Fold the design sketch into step 1, and fix the intro that closes small fixes "with step 6".
3. Add the plan to the knowledge homes in `.rig/playbooks/docs.md`, as the `## Implementation Plan` section of the task that owns the work.
4. Name the plan review in `.rig/playbooks/review.md`: a plan goes to a reviewer before the user approves it, with a 12-turn budget.
5. Gate `AGENTS.md` on the written plan, scope the Tier 0 "Execute first, report after" line to after the plan, and add the plan review and the approval to the Plan phase.
6. Render the install with `sync.sh`, run `tests/test_install.sh` and `tests/test_harness.sh`, and confirm `sync.sh --check` is clean.
7. Review the change with `spec-reviewer` and `docs-reviewer`, because workflow authority changes, then report the commits for the user's go-ahead.
<!-- SECTION:PLAN:END -->
