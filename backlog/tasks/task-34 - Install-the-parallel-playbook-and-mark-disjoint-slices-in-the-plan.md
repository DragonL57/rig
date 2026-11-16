---
id: TASK-34
title: Install the parallel playbook and mark disjoint slices in the plan
status: To Do
assignee: []
created_date: '2026-11-16T04:45:00Z'
updated_date: '2026-11-16T04:49:00Z'
labels: []
dependencies: []
ordinal: 41000
---

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A session reading workflow.md learns that disjoint slices can run in parallel, how to tell they are disjoint, that each slice checks only its own files, and that the parallel path runs no git command.
- [ ] #2 parallel.md is installed as .rig/playbooks/parallel.md, its header no longer says experimental, it names workflow.md steps 1 and 5, it carries no worktree or foundations-commit instruction, and it carries the shared-artifact, scoped-check, and per-slice-diff rules.
- [ ] #3 The kit README lists parallel in the playbook table and no longer calls it experimental.
- [ ] #4 Two implementers run concurrently on disjoint files in one checkout, each slice's check compiles the whole project, neither edits a file outside its set, and the full suite passes after both land.
- [ ] #5 bash ~/.pi/agent/rig/sync.sh --check is up to date, tests/test_install.sh PASS, and ~/.pi/agent/tests/test_harness.sh reports 0 failed.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Move experimental/parallel.md to .rig/playbooks/parallel.md and rewrite it around parallelism with no git command. Delete the worktree section and the commit-the-foundations rule. Keep one sentence on cross-slice contradictions that per-slice reviews cannot see, and point at review.md once. Add three rules: a slice never regenerates a shared artifact such as a lockfile, codegen, formatter output, or snapshot, and the orchestrator alone runs those after all slices land; a slice's check is scoped to its own files, and a failure outside its file set is reported, never edited; the orchestrator inspects each slice with git diff -- <its files> before integrating. Fix its SLYE breaks. Add one line at the top naming workflow.md steps 1 and 5. Check: grep finds no worktree, no commit-the-foundations, no Experimental, then read the result for disjoint files, orchestrator-owns-gaps, cross-slice contradictions, and the small-project guard.
2. workflow.md step 1: the plan marks which slices touch disjoint files and lists each slice's file set, asserting no shared registry, key, migration number, branch, or generated artifact. Name .rig/playbooks/parallel.md. Check: the sentence names the file-ownership test and the path.
3. workflow.md step 5: disjoint slices go to parallel implementers in the same checkout, each running only its own files' checks and reporting a failure outside its file set instead of editing it; the orchestrator runs the full suite once after all slices land. Check: step 5 names the same-checkout rule, the scoped-check rule, and the report-dont-edit rule.
4. workflow.md step 6: one integration review pass for parallel work instead of a review per slice, and add 'or the working diff' to the change definition in the same step. Check: the clause names the single pass and the working diff.
5. workflow.md step 8: the commit happens once, after the spec is done and reviewed, on the user's go-ahead. Check: the sentence exists and names the single commit.
6. Kit README: add the parallel row to the table at README.md:176 and replace the experimental bullet at README.md:211. Check: grep finds no experimental reference to parallel.md.
7. Render and test: bash ~/.pi/agent/rig/sync.sh, then --check, then tests/test_install.sh, then ~/.pi/agent/tests/test_harness.sh. Check: each named command passes.
8. Run the demo: two implementers on disjoint files in one checkout, both slices' checks compiling the whole project, the full suite after. TASK-35 has not landed, so each spawn still starts MCP servers. Check: both slices land, neither edited a file outside its set, and the full suite passes.
<!-- SECTION:PLAN:END -->
