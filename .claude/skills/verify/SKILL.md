---
name: verify
description: Use when the user asks to "verify implementation", "check if done", "validate completeness", "did I miss anything", "check for stubs", or needs post-implementation verification against a plan or acceptance criteria.
argument-hint: "[plan file, feature name, or acceptance criteria]"
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob
---

Verify that an implementation fully achieves its intended goals using three-level artifact checks and anti-pattern scanning.

## Verification Philosophy

- **Three levels, not one** — checking that a file exists is not verification; check existence, then substance, then wiring
- **Evidence-based** — every pass/fail references a specific `file:line`; never claim completion without proof
- **Anti-pattern awareness** — actively scan for common shortcuts that masquerade as completion (stubs, TODOs, empty catches)
- **Confidence markers** — distinguish between verified facts and assumptions; surface uncertainty explicitly
- **Goal-backward** — verify against the intended outcome (observable truths), not just the code that was written

## When to Use

### This Skill Is For

- Verifying a feature implementation is complete (not just "code exists")
- Checking implementation against a plan's observable truths
- Scanning for stubs, placeholders, and incomplete wiring
- Post-implementation quality gate before PR creation
- Validating that acceptance criteria from a Jira ticket are met

### Use a Different Approach When

- Reviewing code quality or style → use `/review`
- Understanding how code works → use `/explore`
- Planning what to build → use `/plan`
- Debugging a failing implementation → use `/debug`

## Input Classification

| Input | Intent | Approach |
|-------|--------|----------|
| Plan file path (e.g., `.planning/STATE.md`) | Verify against plan | Extract observable truths, run three-level checks |
| Feature name (e.g., `user authentication`) | Verify feature completeness | Discover feature scope, then three-level checks |
| Acceptance criteria (inline or file) | Verify against criteria | Parse criteria, map to code, three-level checks |
| Directory (e.g., `src/auth/`) | Verify module completeness | Anti-pattern scan + wiring check |
| `"stubs"` / `"todos"` / `"placeholders"` | Anti-pattern scan only | Focused scan across codebase |
| (none) | Ask user | Pre-flight stop |

## Three-Level Verification

### Level 1: Existence

Does the artifact exist?

- File exists at expected path
- Function/class/export exists with expected name
- Test file exists alongside implementation
- Configuration entries present
- Database migrations exist

### Level 2: Substance

Is the implementation real, not a stub?

- Functions have meaningful bodies (not just `return null`, `throw new Error('TODO')`, `pass`)
- Test assertions are substantive (not just `expect(true).toBe(true)`)
- Error handling has real recovery logic (not empty catch blocks)
- Configuration values are real (not placeholder `xxx` or `TODO`)
- API handlers return real responses (not hardcoded mock data)

### Level 3: Wiring

Is everything connected?

- Exports are imported where needed
- Routes are registered in the router
- Middleware is applied to correct paths
- Event handlers are subscribed
- Database models are used by services (not orphaned)
- Tests are included in test runner configuration
- Environment variables are documented and loaded

## Anti-Pattern Catalog

Actively scan for these patterns that indicate incomplete implementation:

| Anti-Pattern | Detection | Severity |
|---|---|---|
| **TODO/FIXME comments** | Grep for `TODO`, `FIXME`, `HACK`, `XXX` in new/modified files | High |
| **Stub returns** | Functions returning `null`, `undefined`, `{}`, `[]`, `''` without logic | Critical |
| **Placeholder throws** | `throw new Error('Not implemented')`, `throw new Error('TODO')` | Critical |
| **Empty catch blocks** | `catch (e) {}` or `catch (e) { /* ignore */ }` | High |
| **Console-only error handling** | `catch (e) { console.log(e) }` without recovery or re-throw | Medium |
| **Hardcoded test data** | Test assertions against magic numbers without explanation | Low |
| **Orphaned exports** | Exported functions/types not imported anywhere | Medium |
| **Dead imports** | Imported modules not used in the file | Low |
| **Commented-out code** | Large blocks of commented code (>5 lines) | Medium |
| **any types** | TypeScript `any` usage bypassing type safety | Medium |

## Process

### 1. Pre-flight

- Parse `$ARGUMENTS` and map to the appropriate intent using the Input Classification table
- If verifying against a plan, read `.planning/STATE.md` or the specified plan file
- Extract observable truths or acceptance criteria to verify against
- Identify the scope of files and modules to check

**Stop conditions:**
- No `$ARGUMENTS` and no `.planning/STATE.md` found → ask user what to verify
- No clear criteria to verify against → ask user for acceptance criteria or plan
- Scope too broad without criteria → ask user to narrow scope or provide a plan

### 2. Level 1 — Existence Check

For each expected artifact (from observable truths, plan, or inferred scope):

- Verify file exists at expected path
- Verify expected exports/functions/classes exist
- Verify test files exist alongside implementation
- Record: `[EXISTS]` or `[MISSING]` with expected path

### 3. Level 2 — Substance Check

For each artifact that passed Level 1:

- Read the implementation and verify it contains meaningful logic
- Run anti-pattern catalog scans on the file
- Check that test assertions are substantive
- Record: `[SUBSTANTIVE]`, `[STUB]`, or `[PARTIAL]` with `file:line` evidence

### 4. Level 3 — Wiring Check

For each artifact that passed Level 2:

- Verify exports are imported by consuming modules
- Verify routes/handlers are registered
- Verify middleware/interceptors are applied
- Verify event subscriptions are active
- Record: `[WIRED]`, `[ORPHANED]`, or `[PARTIAL]` with `file:line` evidence

### 5. Report

Present structured verification results using confidence markers:

- **PASS** — all three levels verified with evidence
- **PARTIAL** — exists and has substance but wiring incomplete or untested
- **FAIL** — missing, stub, or orphaned
- **SKIP** — could not verify (explain why)

Include:
- Summary: X/Y observable truths verified
- Per-truth breakdown with level results and evidence
- Anti-pattern findings with severity and location
- Recommended actions for any non-PASS results

## Output Principles

- **Structured results** — use tables for verification results; one row per observable truth or artifact
- **Evidence always** — every PASS or FAIL cites `file:line`; never claim status without proof
- **Severity-ranked findings** — Critical > High > Medium > Low; address Critical items first
- **Actionable recommendations** — for every FAIL or PARTIAL, suggest the specific fix needed

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Check for `.planning/STATE.md`; if not found, ask user |
| Plan file path | Extract observable truths from plan, run full verification |
| Feature name | Discover feature scope in codebase, run full verification |
| Acceptance criteria | Parse criteria, map to code artifacts, run full verification |
| Directory path | Anti-pattern scan + wiring check on the specified module |
| `stubs` / `todos` | Focused anti-pattern scan across entire codebase |

## Error Handling

| Scenario | Response |
|----------|----------|
| No criteria to verify against | Ask user for plan, acceptance criteria, or feature name |
| File access fails | Mark as `[SKIP]` with reason, continue with remaining checks |
| Ambiguous scope | Ask user to clarify which feature or module to verify |
| All checks pass | Report PASS with confidence; recommend `/review` for code quality |
| Critical anti-patterns found | Report immediately with exact locations; recommend fixing before PR |
| Plan file outdated | Warn user that plan may not reflect current implementation |

Never silently skip verification steps — surface limitations and skipped items explicitly.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Need code quality review, not completeness verification |
| `/plan` | Need to create a plan before verification |
| `/feature` | Need to implement features, not verify them |
| `/debug` | Implementation has bugs, not just incompleteness |
| `/explore` | Need to understand code before verifying it |
