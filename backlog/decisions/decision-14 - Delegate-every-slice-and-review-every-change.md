---
id: decision-14
title: Split delegation on size, not on judgment
date: '2026-11-16 17:10'
status: accepted
---
## Context

Decision-5 let the orchestrator implement small, short fixes directly and run reviewers only for substantial changes. Neither "small" nor "substantial" had a definition the agent could check, so the judgment belonged to the agent that wanted to skip the spawn. In practice the orchestrator wrote a twenty-file, 152-line change itself and spawned reviewers afterwards, which satisfied every rule in the contract and none of its intent.

The first repair removed the threshold entirely: an `implementer` writes every deliverable file, and every diff gets a reviewer spawn. That failed the other way. A two-line fix cost one implementer spawn and two reviewer spawns, and the operator rejected it as overhead that made small work slower than doing it.

Both failures share one cause: the rule was stated in prose the agent could reinterpret, and the operative gate lost its carve-out each time it was repaired.

## Decision

The split is on size, and the size is countable:

- One file with 30 changed lines or fewer, additions and deletions together: the orchestrator writes it alone. No implementer, no reviewer.
- Everything bigger is a delegated change: the plan names the slices, each slice goes to an `implementer`, and slices that share no file run in parallel.
- A delegated change gets `spec-reviewer` and `taste-reviewer`. A change you write alone gets no reviewer, whatever it changes.
- Every message that reports a change ends with one line naming who wrote it and who reviewed it.

The two branches are exhaustive and exclusive, so no change falls between them and none matches both.

## Consequences

A one-line fix costs one edit. A multi-file change costs a plan and a fan-out. The failure that produced the twenty-file self-written change cannot recur by reinterpreting a threshold, because the branch is a file count and a line count instead of an adjective.

Each subagent starts without the MCP gateway, so an implementer costs about 5.6k tokens and three parallel spawns no longer start three sets of browser servers.

This decision supersedes decision-5 where it allowed direct implementation of small fixes and substantial-only review. It also supersedes the first repair, which required delegation for every change.
