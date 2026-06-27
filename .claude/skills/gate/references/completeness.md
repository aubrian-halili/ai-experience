# Completeness Check (the `/verify` procedure)

The completeness building block of `/gate`. **Self-contained — it never fans out to subagents**, so
it is safe to run inline or as a single nested `Agent` call.

## Input Handling

Default approach: three-level checks (Existence → Substance → Wiring).

| Input | Approach |
|-------|----------|
| Plan file path | Extract observable truths |
| Feature name | Discover feature scope |
| Acceptance criteria | Parse criteria, map to code |
| Directory | Anti-pattern scan + wiring check |
| `"stubs"` / `"todos"` / `"placeholders"` | Focused scan across codebase |

Default diff range: `origin/main..HEAD` (fall back to `HEAD~1..HEAD`). The caller may pass an
explicit range and acceptance criteria.

## Three-Level Verification

- **Level 1 — Existence:** `[EXISTS]` / `[MISSING]` with expected path.
- **Level 2 — Substance:** `[SUBSTANTIVE]` / `[STUB]` / `[PARTIAL]` with `file:line`.
- **Level 3 — Wiring:** `[WIRED]` / `[ORPHANED]` / `[PARTIAL]` with `file:line`.

## Output

- **PASS** — all three levels verified with fresh `file:line` evidence
- **PARTIAL** — exists and substantive but wiring incomplete or untested
- **FAIL** — missing, stub, or orphaned
- **SKIP** — could not verify
