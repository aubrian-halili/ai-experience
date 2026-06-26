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

Always dispatch these subagents. Stage 1 runs concurrently — **one message, parallel `Agent` calls**:

- **`code-quality-reviewer`** — type safety, error handling, test coverage, performance, documentation.
- **`security-scanner`** — OWASP injection, auth/access, crypto, config.
- **`database-explorer`** — *only when the diff touches persisted data* (migrations, schema, ORM models, queries, named entities mapping to tables). Skip otherwise and note the skip.
- **`code-explorer`** — find 2-3 existing siblings of the same archetype as the changed code (e.g. another route handler, another migration, another React hook). Compare the new code against them and report **unjustified divergence** — where the new code departs from the established sibling pattern without a reason evident in the diff. For each divergence, return the sibling's pattern (`file:line`) and the divergent code (`file:line`). If no sibling exists (new/greenfield project, first of its archetype), say so explicitly.

Stage 2 depends on `code-explorer`'s output:

- **`code-architect`** — dispatch in all cases:
  - **Divergences flagged** — one `code-architect` per divergence with the existing sibling pattern and the divergent code; it produces a concrete realignment suggestion. Dispatch concurrently when there is more than one.
  - **No sibling exists** (new project, first of its archetype) — dispatch one `code-architect` with the new code and no prior pattern; it produces the recommended pattern from first principles for the code to follow and future siblings to match.
  - **Siblings exist with no unjustified divergence** — skip; note that the new code aligns with established patterns.

## Process

Review the diff on the current branch; never fetch or checkout. Run the Specialized Review Passes, fold `code-architect`'s realignment suggestions into the divergence findings, then present everything using the template from `@references/templates.md`.
