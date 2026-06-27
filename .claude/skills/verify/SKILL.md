---
name: verify
description: >-
  Standalone completeness check. User asks "did I finish everything", "verify this is done",
  "am I done", "check for stubs, TODOs, or orphaned code", "is this wired up",
  or references a plan's acceptance criteria to verify against.
  Three-level (Existence, Substance, Wiring) check with file:line evidence.
  The completeness building block of /gate.
  Not for: end-to-end PR review or merge-readiness (use /gate); code quality review (use /review);
  not for: addressing PR feedback (use /receiving-review).
argument-hint: "[plan file, feature name, or acceptance criteria]"
allowed-tools: Bash(git *, npm test *, npx jest *, npx vitest *), Read, Grep, Glob
---

**Current branch:** !`git branch --show-current`
**Changed files:** !`git diff --name-only origin/main..HEAD 2>/dev/null || git diff --name-only HEAD~1..HEAD`

Run the completeness procedure in `~/.claude/skills/gate/references/completeness.md` against
`$ARGUMENTS` (or, if none, the current branch diff above). It is self-contained — no subagents.

Emit the three-level findings and a **PASS / PARTIAL / FAIL / SKIP** verdict with `file:line` evidence.
