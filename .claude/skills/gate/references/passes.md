# Specialized Review Passes (the `/review` procedure)

The quality building block of `/gate` and the single source of truth for the review fan-out.

> **Requires the `Agent` tool — dispatch these passes from a main loop.** A spawned agent cannot
> spawn its own subagents. If you are a spawned subagent (no `Agent` tool), STOP and report that the
> review must be run from the main loop — do **not** perform the passes inline, which collapses them
> into a surface scan and misses cross-file divergence and DB-schema issues.

## Reporting Threshold

Only report a finding where `git blame -L <start>,<end> <file>` confirms the issue is introduced by
this change, not pre-existing.

## `--refactor`

When the caller passes `--refactor`, perform a Clean Code & SOLID-focused review with concrete Edit
suggestions (e.g. `src/auth/ --refactor`).

## Stage 1 — concurrent (one message, parallel `Agent` calls)

Give every pass the diff range (`<base>..HEAD`, default `origin/main..HEAD`) and point it at the
branch being reviewed.

- **`code-quality-reviewer`** — type safety, error handling, test coverage, performance, documentation.
- **`security-scanner`** — OWASP injection, auth/access, crypto, config.
- **`code-explorer`** — find 2-3 existing siblings of the same archetype as the changed code (e.g.
  another route handler, another migration, another React hook). Compare the new code against them
  and report **unjustified divergence** — where the new code departs from the established sibling
  pattern without a reason evident in the diff. For each divergence, return the sibling's pattern
  (`file:line`) and the divergent code (`file:line`). If no sibling exists (new/greenfield, first of
  its archetype), say so.
- **`database-explorer`** — **only when the diff touches persisted data** (migrations, schema, ORM
  models, raw/ORM queries, named entities mapping to tables). Pass it the concrete schema questions
  the diff raises (e.g. "does `r_client_score` have an `isactive` column, and how does the sibling
  repository filter it?"). Skip otherwise and note the skip in the verdict.

## Stage 2 — depends on `code-explorer`

- **`code-architect`** — dispatch in all cases:
  - **Divergences flagged** — one `code-architect` per divergence (concurrently) with the existing
    sibling pattern and the divergent code; it produces a concrete realignment suggestion.
  - **No sibling exists** — dispatch one `code-architect` with the new code and no prior pattern; it
    produces the recommended pattern from first principles for the code and future siblings to match.
  - **Siblings exist with no unjustified divergence** — skip; note that the new code aligns with
    established patterns.

Fold `code-architect`'s realignment suggestions into the divergence findings, then present using
`templates.md`.
