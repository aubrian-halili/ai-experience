---
name: debug
description: >-
  User has a bug, error, or failing test — asks to "debug this", "fix this bug",
  "why is this failing", "I'm getting an error", or encounters a stack trace.
  Not for: understanding working code (use /explore), refactoring (use /review --refactor),
  writing new tests (use /testing).
argument-hint: "[bug description, error message, or failing test]"
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
---

Systematically diagnose and fix bugs using a structured reproduce-isolate-hypothesize-fix-verify methodology with built-in guards against analysis paralysis.

## Debugging Philosophy

- **Reproduce first** — never hypothesize without seeing the failure; if you can't reproduce it, you can't verify the fix
- **Minimal fix principle** — change the least code possible to fix the bug; resist the urge to refactor during debugging
- **One hypothesis at a time** — test hypotheses sequentially, not in bulk; changing multiple things obscures the root cause
- **Analysis paralysis guard** — if 5+ files read without forming a hypothesis, stop and regroup with what you know
- **Evidence over intuition** — trace the actual execution path, don't guess from code reading alone

## Iron Laws

> - NO fixes without reproducing the bug first
> - ONE hypothesis at a time — never shotgun debug
> - If 3+ fixes failed, stop and question the architecture

## Rationalization Guard

| Excuse | Reality |
|--------|---------|
| "The fix is obvious, skip reproduction" | Can't verify a fix without confirming the bug first |
| "Let me refactor while I'm here" | Scope creep during debugging obscures root cause |
| "I'll just change a few things and see" | Shotgun debugging wastes time and hides causation |
| "The stack trace tells me everything" | Stack traces show symptoms, not root causes |

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| Error message (e.g., `TypeError: Cannot read property...`) | Trace error | Locate throw site, trace backward |
| Failing test (e.g., `auth.test.ts fails`) | Fix failing test | Run test, read assertion, trace to source |
| Bug description (e.g., `login returns 500`) | Diagnose behavior | Reproduce, isolate, trace |
| Stack trace | Trace from crash site | Parse stack, read each frame, identify root |
| `"regression"` + description | Find what changed | Git bisect / diff-based investigation |
| (none) | Ask user | Pre-flight stop |

## Process

### 1. Reproduce

- Confirm the bug is reproducible with the information provided
- If a test exists, run it and capture the exact failure output
- If no test exists, identify the minimal reproduction steps
- Record the **expected behavior** vs. **actual behavior**

**Stop conditions:**
- Cannot reproduce → ask user for more context (environment, steps, data)
- Bug is intermittent → note flakiness, increase reproduction attempts, check for race conditions

### 2. Isolate

- Narrow the scope from "something is broken" to "this specific code path is wrong"
- Read the error message / stack trace carefully — start from the immediate failure site
- Trace backward through the call chain to find where correct behavior diverges from actual (see `references/root-cause-tracing.md`)
- Identify the **boundary**: the last point where data/state is correct and the first point where it's wrong

**Multi-component systems** (API → service → database, CI → build → deploy):
1. Add diagnostic logging at each component boundary
2. Log what enters and exits each component
3. Run once to gather evidence showing WHERE in the chain it breaks
4. Then investigate the specific failing component — don't guess across boundaries

**Analysis paralysis guard:** If you've read 5+ files without a hypothesis:
1. Stop reading new files
2. Summarize what you know so far
3. List the 2-3 most likely root causes based on evidence
4. Pick the most likely one and test it
5. If wrong, move to the next hypothesis

### 3. Hypothesize

- Form a single, testable hypothesis about the root cause
- State it clearly: "The bug occurs because [specific condition] causes [specific effect] at `file:line`"
- Identify what evidence would confirm or refute the hypothesis
- If multiple hypotheses are equally likely, rank by: (1) simplest explanation, (2) closest to failure site, (3) most recently changed code

### 4. Fix

- Apply the **minimal fix** — change only what's necessary to correct the bug
- Do not refactor, clean up, or improve surrounding code during the fix
- If the fix requires changing a public API, note the impact
- Write or update a test that would have caught this bug

**Fix principles:**
- Prefer fixing the root cause over adding a workaround
- If a workaround is necessary (e.g., third-party bug), document it with a comment explaining why
- If the fix is in a hot path, consider performance implications
- If the fix changes behavior, check for dependent code that relies on the old (buggy) behavior
- After fixing, consider whether defense-in-depth validation is needed (see `references/defense-in-depth.md`)

**3+ fixes failed — stop and question the architecture:**
- Pattern indicators: each fix reveals new shared state or coupling, fixes require massive refactoring, each fix creates symptoms elsewhere
- These signal an architectural problem, not an implementation bug
- Action: stop attempting fixes, discuss with user whether the pattern is fundamentally sound before proceeding

### 5. Verify

- Run the failing test / reproduction steps to confirm the fix works
- Run related tests to check for regressions
- Verify the fix doesn't introduce new anti-patterns (empty catches, stub returns)
- If the original bug was in a critical path, consider edge cases the fix might miss

**Verification checklist:**
- [ ] Original bug no longer reproduces
- [ ] New/updated test covers the bug scenario
- [ ] Related tests still pass
- [ ] Fix is minimal (no unrelated changes)
- [ ] No new anti-patterns introduced

## Debugging Techniques

**Binary Search (Bisect):** When the bug is a regression, use `git bisect` or manual halving to find the introducing commit.

**Print Debugging:** Add targeted logging at key points in the execution path. Remove all debug logging before committing.

**Rubber Duck:** If stuck, explain the problem step-by-step to yourself. The act of articulating often reveals the flaw.

**Invert the Question:** Instead of "why does it fail?", ask "what conditions would make it succeed?" and check which condition is violated.

**Check the Boundaries:** Bugs cluster at boundaries — between modules, between async operations, at type conversions, at null checks, at array indices.

## Output Principles

- **Structured diagnosis** — present findings as: Symptom → Root Cause → Fix → Verification
- **Evidence-based** — every claim references `file:line`; never say "the problem is probably..."
- **Minimal diff** — show only the changed code, not the entire file
- **Prevention note** — briefly note how this class of bug could be prevented (better types, tests, validation)

## Error Handling

| Scenario | Response |
|----------|----------|
| Cannot reproduce | Ask for more context: environment, exact steps, sample data |
| Multiple bugs entangled | Isolate and fix one at a time; note the others |
| Fix introduces new failures | Revert, re-analyze; the hypothesis may be wrong |
| Root cause is in external dependency | Document the limitation, implement a workaround with explanation |
| Analysis paralysis (5+ files, no hypothesis) | Stop, summarize findings, force a ranked hypothesis list |
| Fix requires large refactor | Report the scope, ask user whether to proceed or apply a targeted workaround |

Never silently abandon a debugging path — if switching approaches, explain why the previous path was unproductive.

## Supporting Techniques

| Reference | Purpose |
|-----------|---------|
| `references/root-cause-tracing.md` | 5-step backward trace through the call stack to find root cause |
| `references/defense-in-depth.md` | Add validation at multiple layers after finding root cause |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/explore` | Need to understand working code, not fix broken code |
| `/review` | Code works but needs quality review |
| `/feature` | Need to add new functionality, not fix existing |
| `/verify` | Need to check completeness, not fix a bug |
| `/testing` | Need to write new tests, not debug failing ones |
