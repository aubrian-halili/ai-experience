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

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| Plan file path (e.g., `.planning/STATE.md`) | Verify against plan | Extract observable truths, run three-level checks |
| Feature name (e.g., `user authentication`) | Verify feature completeness | Discover feature scope, then three-level checks |
| Acceptance criteria (inline or file) | Verify against criteria | Parse criteria, map to code, three-level checks |
| Directory (e.g., `src/auth/`) | Verify module completeness | Anti-pattern scan + wiring check |
| `"stubs"` / `"todos"` / `"placeholders"` | Anti-pattern scan only | Focused scan across codebase |

## Three-Level Verification

### Level 1: Existence — record `[EXISTS]` or `[MISSING]` with expected path

- File exists at expected path
- Function/class/export exists with expected name
- Test file exists alongside implementation
- Configuration entries present
- Database migrations exist

### Level 2: Substance — record `[SUBSTANTIVE]`, `[STUB]`, or `[PARTIAL]` with `file:line` evidence

Run the full anti-pattern scan from `@references/anti-patterns.md` (Iron Law #3).

- Functions have meaningful bodies (not just `return null`, `throw new Error('TODO')`, `pass`)
- Test assertions are substantive (not just `expect(true).toBe(true)`)
- Error handling has real recovery logic (not empty catch blocks)

### Level 3: Wiring — record `[WIRED]`, `[ORPHANED]`, or `[PARTIAL]` with `file:line` evidence

- Exports are imported where needed
- Routes are registered in the router
- Middleware is applied to correct paths
- Event handlers are subscribed
- Database models are used by services (not orphaned)
- Tests are included in test runner configuration
- Environment variables are documented and loaded

## Process

**Stop condition:** Verifying against a plan but no plan file resolves → ask for the path.

Present structured verification results using confidence markers:

- **PASS** — all three levels verified with evidence
- **PARTIAL** — exists and has substance but wiring incomplete or untested
- **FAIL** — missing, stub, or orphaned
- **SKIP** — could not verify (explain why)
