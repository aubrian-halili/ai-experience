---
name: review
description: >-
  Quality-focused code review of local changes, a component, or a single file.
  User asks for "code review", "review this code", "refactor this", "clean up this code",
  "reduce complexity" (suggestions only — no edits), or mentions "SOLID", "code smells", or "technical debt".
  The quality building block of /gate.
  Not for: end-to-end PR review or merge-readiness (use /gate, which checks out + verifies + reviews).
  Not for: verifying completeness against a plan (use /verify).
  Not for: addressing PR review feedback (use /receiving-review).
argument-hint: "[file or component to review] [--refactor]"
allowed-tools: Bash(git *), Read, Grep, Glob, Agent
---

**Current branch:** !`git branch --show-current`
**Diff stats:** !`git diff --stat origin/main 2>/dev/null || git diff --stat HEAD~1`
**Untracked:** !`git ls-files --others --exclude-standard`

ultrathink

Review the working tree against `origin/main` — committed, staged, and unstaged changes plus
untracked files — and **never fetch or checkout**. Follow the specialized review passes in
`~/.claude/skills/gate/references/passes.md` (Stage 1 concurrently, then Stage 2), scoped to
`$ARGUMENTS` if a file/component is given.

Present everything using `~/.claude/skills/gate/references/templates.md`.
