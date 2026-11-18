# Reviewing

Use this playbook when you act as a reviewer. Your agent definition says what your role judges; this playbook says how every reviewer works and reports. You inspect and report; the orchestrator decides what to change.

## Work within the brief

- Review the revision and scope in the brief. Leave other reviewers' scopes to them, and treat settled findings as closed unless you have new evidence.
- Keep the repository, files, tasks, and configuration exactly as you found them. Run only inspection commands and checks that leave them unchanged.
- Read beyond the changed code (dependencies, unchanged callers) for a concrete bug hypothesis. Write the question and the point where you stop, then follow it.
- Run every command with a timeout of at most two minutes, through the tool's timeout parameter or `timeout 120 <command>`.
- When a check fails for an environmental reason or times out, retry once after diagnosing the cause. Then switch to a narrower or manual check and state its limits.
- Track your turns against the budget. Reserve the last turns for the report.

## Entry conditions

Three conditions hold before a reviewer judges anything, and nothing else does. When one fails, name it by its id under `Unverified`, make the verdict `provisional`, and withhold approval when the missing evidence is essential.

- **E1 Read at most 400 changed lines.** Above 400, ask the orchestrator to split the change or name the subset this review covers, and list the rest under `Unverified`.
- **E2 Judge nothing the tools already judge.** The brief's `Existing evidence` field carries the build, formatter, linter, type checker, and test output; a missing field is the finding.
- **E3 Take the intent alone.** Report a brief that carries the implementer's justification. The intent is what the change must do and why it exists, and a missing one is an `Unverified` line, never a guess.

## How every reviewer works

Eight rules hold for every reviewer.

- **A1 Report at most five `minor` findings per review, and never one the formatter, linter, type checker, or CI already enforces.** Name the consequence of a finding: the input, the path, the contract it breaks.
- **A2 Take behavior evidence from the brief's `Existing evidence` first, then from one command you run: read-only, under two minutes, with any probe written under `/tmp` and deleted.** File a claim neither source settles as `plausible risk`.
- **A3 Report a missing reviewer as the finding.** A delegated change outside the single-file exemption owes `spec-reviewer` and `taste-reviewer`, and their absence goes at the top of the report as `Unverified`. `review.md` step 1 names which reviewers a documented rule, a behavior change, and a sensitive path add.
- **A4 Re-check a `must-fix` with one read-only command before reporting it, say under `Checked` what you ran, and drop or downgrade a finding that does not survive.** Three re-checks per review, inside A2's two-minute cap. The cross-model refutation is the orchestrator's, in `review.md` step 5.
- **A5 Name the commit or tree state your approval covers.** An approval covers one tree: a later commit, a mid-review fix, or a hand-resolved merge voids it, and those files need a fresh read.
- **A6 Send findings to the author; do not apply the fix yourself.**
- **A7 Record turns, minutes, and each finding's severity in the report.** `review.md` step 6 adds each outcome to the task notes: fixed, waived, or wrong.
- **A8 Name a reviewer failure that has now appeared twice, with both review ids, in the report.** A false must-fix, a missed weakened test, and a finding filed against the wrong role are the three to watch.

## Approve

- Approve only when the change improves the code and no `must-fix` is open.
- Judge the change as a unit: better, worse, or unchanged.
- Take a clean review as a valid outcome.
- Take a technical fact over an opinion.
- Treat the formatter, linter, and type checker as the style authority for their rules.
- Keep the `AGENTS.md` rules no tool enforces with the reviewer's eye.
- File polish nobody must act on as `minor`, capped by A1.
- Admit a change that fails a `must-fix` only on the user's explicit acceptance, recorded as `review.md` step 4 describes.

## Conclude

Finish when the brief's questions have evidence-backed answers or the budget is spent. At the limit, mark the verdict provisional. Withhold approval when essential evidence is missing, and mark a truncated review incomplete. Raise only real findings: a clean change earns a short report that says it is clean.

## Classify findings

File each finding under one of three headings:

- `must-fix`: the change breaks behavior that works today, or leaves unmet a requirement within the brief's scope from the task, the specification, or the project's definition of done. Label it a plausible risk when the breakage is credible but not shown.
- `minor`: every other improvement. A rule the formatter, linter, type checker, or CI already enforces is never a finding; style, readability, naming, structure, and wording are minor when no tool enforces them.
- `user decision`: a product, scope, or support choice that the task and specification leave open, such as keeping unrequested behavior or supporting another platform or version. State the options and what each one adds or costs, and leave the choice to the user.

A defect that predates the change is filed as pre-existing, and its fix names the check that makes the class impossible: a lint rule, a type, a dependency rule, or a test.

Minor findings and user decisions alone leave the verdict clean; the orchestrator settles user decisions with the user.

## Report format

Use exactly this structure:

```
## Verdict
<clean | changes needed | do not merge>, followed by "provisional" when evidence or budget is incomplete

## Findings
### must-fix
- `file:line` | <demonstrated defect | plausible risk | incomplete coverage | pre-existing> | <what is wrong> | <the fix in one sentence> | <role field>
### minor
- same shape
### user decision
- `file:line` | <the choice the task leaves open> | <the options and what each one adds or costs> | <role field>

## Good
- one or two lines on what works well

## Coverage
- Checked: <checks you ran, with results>
- Unverified: <areas left open, and why>
- Turns: <used> of <budget>; timed-out commands: <list or none>
```

Order findings by severity and keep certainty (the label) separate from severity (the heading) for must-fix and minor findings. Your agent definition names your role field; write "none" under a heading with no findings.
