---
name: gate
description: >-
  End-to-end completion gate. User asks to "review this PR", "is this ready to merge",
  "check this PR / feature", or wants a feature gated before handoff.
  Auto-checks-out the PR, derives requirements (PR description for PRs, .planning/STATE.md for features),
  then runs completeness verification and code review IN PARALLEL and emits one combined verdict.
  Not for: standalone completeness check (use /verify); standalone quality review of local code (use /review);
  addressing PR review feedback (use /receiving-review).
argument-hint: "[PR number/URL, or nothing to gate the current feature]"
allowed-tools: Bash(git *, gh *), Read, Grep, Glob, Agent, AskUserQuestion
---

**Current branch:** !`git branch --show-current`
**Working tree:** !`git status --porcelain | head -1 | grep -q . && echo dirty || echo clean`

ultrathink

## Mode detection

| Input | Mode | Requirements source |
|-------|------|---------------------|
| PR number or URL | **PR** | PR description (derived in §PR mode) |
| (none) + `.planning/STATE.md` exists | **Feature** | `.planning/STATE.md` Definition of Done |
| (none) + no `.planning/STATE.md` | Ask the user which PR number or feature to gate, then re-enter |

## PR mode

### 1. Pre-flight

- Refuse if the working tree is dirty (see **Working tree** above) — stop and report.
- `gh pr view <number> --json state,isDraft,author,labels,headRefName,title,body`
- **Stop conditions:** draft PR → report and stop; bot author (e.g. `dependabot`, `renovate`) → report and stop.

### 2. Fetch PR locally

Pull the PR head into a local branch so the diff and `git blame` are available to both passes. Record the base branch from `gh pr view` for the diff range.

- If `pr-<number>` already exists locally:
  - `git fetch origin "pull/<number>/head"`.
  - Check for local-only commits: `git log FETCH_HEAD..pr-<number> --oneline`. If any exist, stop and report — do not overwrite local work.
  - Check if behind: `git log pr-<number>..FETCH_HEAD --oneline`. If empty, skip to checkout. Otherwise fast-forward: `git fetch origin "pull/<number>/head:pr-<number>"`.
- Otherwise: `git fetch origin "pull/<number>/head:pr-<number>"`.
- Then: `git checkout pr-<number>`.

### 3. Derive requirements

- Read the PR `title` + `body`; extract the intended behavior / acceptance criteria.
- **Sufficiency check** — the body is sufficient only if it states what the change should *do*: observable behavior, scope, or linked acceptance criteria. A bare title, "WIP", or an unfilled template is **not** sufficient.
- If insufficient → use `AskUserQuestion` to ask for the requirements / acceptance criteria **before proceeding**. Do not guess or infer scope from the diff alone.

### 4. Gate (parallel)

> **Do NOT nest the review fan-out.** A spawned agent cannot spawn its own subagents. If you wrap `/review` in a single `Agent` call, its Specialized Review Passes (`code-quality-reviewer`, `security-scanner`, `code-explorer`, `database-explorer`, `code-architect`) silently collapse into one inline scan — which misses cross-file sibling divergence and DB-schema issues (e.g. an inlined query that duplicates an existing repository, or a missing `WHERE isactive` filter). The review passes MUST be dispatched from **this (main) loop**, where the `Agent` tool is available. Only `verify` may be nested, because it is self-contained and never fans out.

All `~/.claude/...` paths below are user-level — resolve them against $HOME, not the repo working directory.

Dispatch concurrently from the main loop — **one message** containing all of:

- **Verify** (one nested `Agent` call) — "Read and follow the skill at `~/.claude/skills/verify/SKILL.md` to a PASS/PARTIAL/FAIL/SKIP verdict, checking the checked-out branch against these acceptance criteria: <derived requirements>. Diff range `<base>..HEAD`. Return the verdict with `file:line` evidence."
- **Review — Stage 1 passes** — read `~/.claude/skills/review/SKILL.md` yourself, then dispatch ITS "Specialized Review Passes" as individual `Agent` calls in this same message:
  - `code-quality-reviewer` — type safety, error handling, test coverage, performance, documentation.
  - `security-scanner` — OWASP injection, auth/access, crypto, config.
  - `code-explorer` — find 2-3 existing siblings of the changed code's archetype; report unjustified divergence with `file:line` for both the sibling pattern and the divergent code.
  - `database-explorer` — **only when the diff touches persisted data** (migrations, schema, ORM models, raw/ORM queries, named entities mapping to tables). Pass it the concrete schema questions the diff raises (e.g. "does `r_client_score` have an `isactive` column, and how does the sibling repository filter it?"). Skip otherwise and note the skip in the verdict.
  - Give each pass the diff range `<base>..HEAD` and point it at the checked-out branch.

Then **Review — Stage 2** (depends on `code-explorer`): per the review skill, dispatch `code-architect` (one per divergence, concurrently) for realignment suggestions, and fold them into the divergence findings.

Combine verify + all review findings into one verdict using `@references/templates.md`.

## Feature mode

Requirements source = the **Definition of Done / Observable Truths** in `.planning/STATE.md`. No checkout (already on the feature branch).

Dispatch using the **same topology as §4**, with two deltas: requirements come from `.planning/STATE.md` (Verify reads `~/.claude/skills/verify/SKILL.md` against it), and the diff range is `origin/main..HEAD`.

Then emit the combined verdict.

## Combined verdict

- **READY** — VERIFY is **PASS** *and* REVIEW has no Blocking or correctness findings.
- **BLOCKED** — anything else. List exactly what blocks, each with `file:line`.

## Related Skills

- `/verify`, `/review` — the building blocks this skill runs in parallel; invoke them directly for a single dimension.
- `/receiving-review` — after the gate, to address reviewer feedback.
