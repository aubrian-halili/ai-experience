---
name: verify
description: >-
  User asks "did I finish everything", "verify this is done", "am I done",
  "check for stubs, TODOs, or orphaned code", "is this wired up",
  or references a plan's acceptance criteria to verify against.
  Three-level (Existence, Substance, Wiring) check with file:line evidence. Use after /feature.
  Not for: code quality review (use /review); not for: addressing PR feedback (use /receiving-review).
argument-hint: "[plan file, feature name, or acceptance criteria]"
allowed-tools: Bash(git *, npm test *, npx jest *, npx vitest *), Read, Grep, Glob
---

**Current branch:** !`git branch --show-current`
**Changed files:** !`git diff --name-only origin/main..HEAD 2>/dev/null || git diff --name-only HEAD~1..HEAD`

## Input Handling

Default approach: three-level checks (Existence → Substance → Wiring).

| Input | Approach |
|-------|----------|
| Plan file path | Extract observable truths |
| Feature name | Discover feature scope |
| Acceptance criteria | Parse criteria, map to code |
| Directory | Anti-pattern scan + wiring check |
| `"stubs"` / `"todos"` / `"placeholders"` | Focused scan across codebase |

## Three-Level Verification

- **Level 1 — Existence:** `[EXISTS]` / `[MISSING]` with expected path.
- **Level 2 — Substance:** `[SUBSTANTIVE]` / `[STUB]` / `[PARTIAL]` with `file:line`. Scan for stubs, placeholder throws, empty catches, TODO/FIXME.
- **Level 3 — Wiring:** `[WIRED]` / `[ORPHANED]` / `[PARTIAL]` with `file:line`. Check imports, routes, middleware, handlers, config.

## Output

- **PASS** — all three levels verified with fresh `file:line` evidence
- **PARTIAL** — exists and substantive but wiring incomplete or untested
- **FAIL** — missing, stub, or orphaned
- **SKIP** — could not verify
