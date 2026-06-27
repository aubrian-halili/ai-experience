---
name: gate
description: >-
  End-to-end completion gate, and the canonical home of the completeness + quality checks.
  User asks to "review this PR", "is this ready to merge", "check this PR / feature",
  or wants a feature gated before handoff.
  Auto-checks-out the PR, derives requirements (PR description for PRs, .planning/STATE.md for features),
  then runs completeness verification and code review IN PARALLEL and emits one combined verdict.
  Not for: standalone completeness check (use /verify); standalone quality review of local code (use /review);
  addressing PR review feedback (use /receiving-review).
argument-hint: "[PR number/URL, or nothing to gate the current feature]"
allowed-tools: Bash(git *, gh *, npm test *, npx jest *, npx vitest *), Read, Grep, Glob, Agent, AskUserQuestion
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

All `references/...` paths below are relative to this skill directory. When invoked at user level,
resolve them against `~/.claude/skills/gate/references/...` ($HOME, not the repo working directory).

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

Dispatch everything from **this (main) loop** in **one message** — never wrap the review in a single
`Agent` call (see the nesting rule in `references/passes.md`). The diff range is `<base>..HEAD`.

- **Completeness** — one `Agent` call following `references/completeness.md` against the derived
  requirements. It is self-contained and never fans out, so nesting it is safe.
- **Review — Stage 1** — dispatch the specialized passes from `references/passes.md` as individual
  `Agent` calls in this same message (`code-quality-reviewer`, `security-scanner`, `code-explorer`,
  and `database-explorer` only when the diff touches persisted data).

Then **Review — Stage 2** (depends on `code-explorer`): dispatch `code-architect` per
`references/passes.md` and fold the realignment suggestions into the divergence findings.

Combine completeness + all review findings into one verdict using `references/templates.md`.

## Feature mode

Requirements source = the **Definition of Done / Observable Truths** in `.planning/STATE.md`. No checkout (already on the feature branch).

Dispatch using the **same topology as §4**, with two deltas: requirements come from `.planning/STATE.md` (completeness runs `references/completeness.md` against it), and the diff range is `origin/main..HEAD`.

Then emit the combined verdict.

## Combined verdict

- **READY** — completeness is **PASS** *and* review has no Blocking or correctness findings.
- **BLOCKED** — anything else. List exactly what blocks, each with `file:line`.

## Related Skills

- `/verify`, `/review` — thin shims over `references/completeness.md` and `references/passes.md`; invoke them directly for a single dimension.
- `/receiving-review` — after the gate, to address reviewer feedback.
