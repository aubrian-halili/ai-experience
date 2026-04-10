---
name: verify
description: >-
  User asks "did I finish everything", "verify this is done", "am I done",
  "check for stubs or TODOs", or references a plan to verify against. Use after /feature.
  Not for: code quality review (use /review).
argument-hint: "[plan file, feature name, or acceptance criteria]"
allowed-tools: Bash(git *, npm test *, npx jest *, npx vitest *), Read, Grep, Glob
---

**Current branch:** !`git branch --show-current`
**Changed files:** !`git diff --name-only origin/main..HEAD 2>/dev/null || git diff --name-only HEAD~1..HEAD`

Verify that an implementation fully achieves its intended goals using three-level artifact checks and anti-pattern scanning.

See `@references/verification-discipline.md` for the behavioral rules that apply during any workflow, not just when `/verify` is invoked.

## Iron Laws

> - NO "PASS" status without `file:line` evidence in the current message
> - NO Level 1 check substitutes for Level 2 or Level 3 — all three levels are required
> - NO anti-pattern scan skipped — run the full catalog on every changed file

Apply the rationalization guards from `@references/verification-discipline.md` before claiming any status.

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| Plan file path (e.g., `.planning/STATE.md`) | Verify against plan | Extract observable truths, run three-level checks |
| Feature name (e.g., `user authentication`) | Verify feature completeness | Discover feature scope, then three-level checks |
| Acceptance criteria (inline or file) | Verify against criteria | Parse criteria, map to code, three-level checks |
| Directory (e.g., `src/auth/`) | Verify module completeness | Anti-pattern scan + wiring check |
| `"stubs"` / `"todos"` / `"placeholders"` | Anti-pattern scan only | Focused scan across codebase |

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

Run the full anti-pattern scan from `@references/anti-patterns.md` on every changed file.

## Process

### 1. Pre-flight

- Parse `$ARGUMENTS` and map to the appropriate intent using the Input Handling table
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

## Error Handling

| Scenario | Response |
|----------|----------|
| Ambiguous scope | Ask user to clarify which feature or module to verify |
| Critical anti-patterns found | Report immediately with exact locations; recommend fixing before PR |
| Plan file outdated | Warn user that plan may not reflect current implementation |
| User asks to skip verification | Explain what verification protects against; offer reduced-scope check rather than none |
