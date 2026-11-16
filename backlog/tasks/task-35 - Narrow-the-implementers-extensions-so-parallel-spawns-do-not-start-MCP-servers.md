---
id: TASK-35
title: Drop the MCP gateway from every subagent
status: To Do
assignee: []
created_date: '2026-11-16T04:46:00Z'
updated_date: '2026-11-16T05:01:00Z'
labels: []
dependencies: []
ordinal: 42000
---

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Every agent file carries exclude_extensions: pi-mcp-adapter.
- [ ] #2 A bare implementer keeps replace, replace_match, and insert, has no mcp or chrome_devtools tool, and starts at about 5.6k tokens instead of 29.1k.
- [ ] #3 tool_search returns no matching tools for a chrome devtools query, so the deferred path cannot pull the servers back.
- [ ] #4 A bare spec-reviewer keeps read and bash, has no mcp tool, and fires no extension-error.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add exclude_extensions: pi-mcp-adapter to agents/implementer.md. The three chrome-devtools namespaces come from that gateway; settings.json already carries extensions: ['-builtin:mcp'] and mcp.json is empty, so builtin:mcp is a no-op here. Check: the rendered ~/.pi/agent/agents/implementer.md carries the line.
2. Spawn one bare implementer and ask it to list its tools. Check: replace, replace_match, and insert are present, mcp__chrome_devtools is absent, and no extension-error warning fires.
3. Measure the context cost before and after. Check: the reported token count drops from 29.1k.
<!-- SECTION:PLAN:END -->
