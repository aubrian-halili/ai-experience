---
name: review
description: >-
  Quality-focused code review of local changes, a component, or a single file.
  User asks for "code review", "review this code", "refactor this", "clean up this code",
  "reduce complexity", or mentions "SOLID", "code smells", or "technical debt".
  The quality building block of /gate.
  Not for: end-to-end PR review or merge-readiness (use /gate, which checks out + verifies + reviews).
  Not for: verifying completeness against a plan (use /verify).
  Not for: addressing PR review feedback (use /receiving-review).
argument-hint: "[file or component to review] [--refactor]"
allowed-tools: Bash(git *), Read, Grep, Glob, Agent
---

**Current branch:** !`git branch --show-current`
**Diff stats:** !`git diff --stat origin/main..HEAD 2>/dev/null || git diff --stat HEAD~1..HEAD`

ultrathink

## Reporting Threshold

Only report a finding where `git blame -L <start>,<end> <file>` confirms the issue is introduced by this change, not pre-existing.

## Input Handling

Pass `--refactor` to perform a Clean Code & SOLID-focused review with Edit suggestions (e.g., `src/auth/ --refactor`).

## Specialized Review Passes

For large scopes (>10 files), dispatch `code-quality-reviewer` and `security-scanner` subagents.

## Process

Review the diff on the current branch. Operate on the already-checked-out branch; never fetch or checkout. Present findings using the template from `@references/templates.md`.
