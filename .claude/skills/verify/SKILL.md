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

## Iron Laws

> - NO "PASS" status without `file:line` evidence in the current message
> - NO completion claim without fresh terminal output as evidence

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

Check that expected files, exports, routes, and config entries exist at their expected locations.

### Level 2: Substance — record `[SUBSTANTIVE]`, `[STUB]`, or `[PARTIAL]` with `file:line` evidence

Run anti-pattern scan on all changed files (stubs, placeholder throws, empty catches, TODO/FIXME markers).

### Level 3: Wiring — record `[WIRED]`, `[ORPHANED]`, or `[PARTIAL]` with `file:line` evidence

Verify all components are connected end-to-end (imports, routes, middleware, handlers, config).

## Process

**Stop condition:** Verifying against a plan but no plan file resolves → ask for the path.

Present structured verification results using confidence markers:

- **PASS** — all three levels verified with evidence
- **PARTIAL** — exists and has substance but wiring incomplete or untested
- **FAIL** — missing, stub, or orphaned
- **SKIP** — could not verify (explain why)
