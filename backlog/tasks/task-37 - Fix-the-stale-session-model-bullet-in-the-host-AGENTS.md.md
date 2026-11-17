---
id: TASK-37
title: Fix the stale session-model bullet in the host AGENTS.md
status: To Do
assignee: []
created_date: '2026-11-17T02:32:00Z'
updated_date: '2026-11-17T02:32:00Z'
labels: []
dependencies: []
ordinal: 44000
---

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The bullet no longer claims agents inherit the session model
- [ ] #2 The replacement names mistral/deepseek-v4-1-flash-1017 and the per-role effort ladder
- [ ] #3 The fallback-runner sentence survives unchanged
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Rewrite `~/.pi/agent/AGENTS.md:184`, which reads "Agents inherit the session model. Give `fallback-runner` an explicit model different from the writer's, and report every substitution." Replace it with the truth HARNESS.md records: every role runs `mistral/deepseek-v4-1-flash-1017`, and the effort ladder is the only difference. Keep the fallback-runner clause, which is still correct.

2. Change nothing in the kit. `/home/thelong/rig/agents/*.md` correctly carry no `model:` line, because the kit is the source and the installer pins at render time. `sync.sh` renders only `.rig/playbooks/` and `agents/`, so this file is hand-maintained and a direct edit will not be reverted.

3. Verify by reading the file back and confirming the sentence matches `~/.pi/agent/HARNESS.md` line 49-52, which states the same ladder.

Done when: `grep -n 'inherit the session model' ~/.pi/agent/AGENTS.md` returns nothing, and the replacement sentence names the model and the effort ladder.
<!-- SECTION:PLAN:END -->
