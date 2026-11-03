# Specialized Review Passes (the `/review` procedure)

The quality building block of `/gate` and the single source of truth for the review fan-out.

> **Requires the `Agent` tool — dispatch these passes from a main loop.** A spawned agent cannot
> spawn its own subagents. If you are a spawned subagent (no `Agent` tool), STOP and report that the
> review must be run from the main loop — do **not** perform the passes inline, which collapses them
> into a surface scan and misses cross-file divergence and DB-schema issues.

## Provenance and citations (dispatcher-owned)

Stage-1 sub-agents have only `Read`/`Grep`/`Glob` — they cannot run `git blame` and may cite a
`file:line` lifted from a diff hunk header or a sibling file. Before folding any finding into the
verdict, run `git blame -L <start>,<end> <file>`: report the finding only if the lines are introduced
by this change (lines shown as `Not Committed Yet` count), and **drop or repair** any finding whose
range doesn't exist or doesn't match the cited code.

## `--refactor`

When the caller passes `--refactor`, perform a Clean Code & SOLID-focused review with concrete Edit
suggestions (e.g. `src/auth/ --refactor`).

## Stage 1 — concurrent (one message, parallel `Agent` calls)

Give every pass the diff the caller sets — `<base>..HEAD` from `/gate`; for `/review`, the working
tree against `origin/main` (`git diff origin/main`, committed + staged + unstaged, plus untracked
files) — and point it at the branch being reviewed.

- **`code-quality-reviewer`** — one call per dimension (the agent takes one per invocation): type
  safety, error handling, test coverage, performance, documentation; the documentation call also
  applies **Comment noise** below.
- **`security-scanner`** — one call per threat category (the agent takes one per invocation):
  Injection & Input, Auth & Access, Data & Crypto, Config & Dependencies.
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

## Comment noise

Covers only comments **added or modified by the diff**; pre-existing comments on untouched lines are
out of scope.

Flag a comment when it earns nothing the code does not already say:

- **Narrates the change** — `// added for UN-1234`, `// new logic`, `// was: ...`, commented-out code
  left behind.
- **Duplicates a nearby comment** — the same explanation on the caller and the callee, or once per
  branch of the same `if`.
- **Is stale** — describes behavior the diff changed, or references a renamed/removed symbol.
- **Restates the code or labels self-evident structure** — `// increment counter`, `// imports`,
  banner separators.

When in doubt, keep the comment.

Report each as **Non-blocking** with `file:line`, the comment text, and `delete` or a shorter
replacement — except a *stale* comment that misdescribes current behavior, which is Blocking when it
would mislead a maintainer.

## Stage 2 — depends on `code-explorer`

- **`code-architect`** (focus: Minimal Changes) — by `code-explorer`'s result:
  - **Divergences flagged** — one `code-architect` per divergence (concurrently) with the existing
    sibling pattern and the divergent code; it produces a concrete realignment suggestion.
  - **No sibling exists** — dispatch one `code-architect` with the new code and no prior pattern; it
    produces the recommended pattern from first principles for the code and future siblings to match.
  - **Siblings exist with no unjustified divergence** — skip; note that the new code aligns with
    established patterns.

Fold `code-architect`'s realignment suggestions into the divergence findings, then present using
`templates.md`.
