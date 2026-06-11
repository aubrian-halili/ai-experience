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

- Refuse if the working tree is dirty (`git status --porcelain` non-empty) — stop and report. Checkout would clobber uncommitted work.
- `gh pr view <number> --json state,isDraft,author,labels,headRefName,title,body`
- **Stop conditions:** draft PR → report and stop; bot author (e.g. `dependabot`, `renovate`) → report and stop.

### 2. Checkout

- `gh pr checkout <number>` — checks out the PR head locally so the diff and `git blame` are available to both passes. Record the base branch from `gh pr view` for the diff range.

### 3. Derive requirements

- Read the PR `title` + `body`; extract the intended behavior / acceptance criteria.
- **Sufficiency check** — the body is sufficient only if it states what the change should *do*: observable behavior, scope, or linked acceptance criteria. A bare title, "WIP", or an unfilled template is **not** sufficient.
- If insufficient → use `AskUserQuestion` to ask for the requirements / acceptance criteria **before proceeding**. Do not guess or infer scope from the diff alone.

### 4. Gate (parallel)

Dispatch both passes concurrently — **one message, two `Agent` calls**:

- **Verify agent** — "Follow `.claude/skills/verify/SKILL.md` to a PASS/PARTIAL/FAIL/SKIP verdict, checking the checked-out branch against these acceptance criteria: <derived requirements>. Diff range `<base>..HEAD`. Return the verdict with `file:line` evidence."
- **Review agent** — "Follow `.claude/skills/review/SKILL.md` to review the diff on the currently checked-out branch (diff range `<base>..HEAD`). Skip its PR pre-flight and checkout — the branch is already current. Return findings grouped by severity with `file:line`."

Combine both into one verdict using `@references/templates.md`.

## Feature mode

Requirements source = the **Definition of Done / Observable Truths** in `.planning/STATE.md`. No checkout (already on the feature branch).

Dispatch the same two passes in parallel:
- **Verify agent** — follow `.claude/skills/verify/SKILL.md` against `.planning/STATE.md`.
- **Review agent** — follow `.claude/skills/review/SKILL.md` on the diff vs `origin/main`.

Then emit the combined verdict.

## Combined verdict

- **READY** — VERIFY is **PASS** *and* REVIEW has no Blocking or correctness findings.
- **BLOCKED** — anything else. List exactly what blocks, each with `file:line`.

## Related Skills

- `/verify`, `/review` — the building blocks this skill runs in parallel; invoke them directly for a single dimension.
- `/receiving-review` — after the gate, to address reviewer feedback.
