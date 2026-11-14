---
name: gate
description: >-
  End-to-end merge-readiness gate for a PR or a planned feature: checks out the PR, derives
  requirements, runs completeness verification and code review in parallel, and emits one
  READY/BLOCKED verdict. Use when the user asks to "review this PR", "is this ready to merge",
  "check this PR / feature", "gate this", "re-gate" or "run the gate again" after fixes, or wants
  a feature gated before handoff.
  Not for: standalone completeness check (use /verify); standalone quality review of local code (use /review);
  addressing PR review feedback (use /receiving-review).
argument-hint: "[PR number/URL, or nothing to gate the current feature]"
allowed-tools: Bash(git *, gh *, npm test *, npx jest *, npx vitest *, npx tsc *, npx eslint *), Read, Grep, Glob, Agent, AskUserQuestion
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

When invoked at user level, resolve `references/...` against `~/.claude/skills/gate/references/`
($HOME, not the repo working directory).

**Re-run** = this conversation already holds a gate verdict for the same PR or feature; otherwise
it is a first run. Re-runs follow **Pre-regate sweep** below and **Re-runs** in `references/passes.md`.

## PR mode

### 1. Pre-flight

- Refuse if the working tree is dirty (see **Working tree** above) — stop and report.
- `gh pr view <number> --json state,isDraft,author,labels,baseRefName,headRefName,title,body`
- **Stop conditions** (report and stop): `state` is not `OPEN`; draft PR; bot author (e.g. `dependabot`, `renovate`).

### 2. Fetch PR locally

- If `pr-<number>` already exists locally: `git fetch origin "pull/<number>/head"`, then `git log FETCH_HEAD..pr-<number> --oneline` — any local-only commits → stop and report.
- `git fetch origin "pull/<number>/head:pr-<number>"` (creates, fast-forwards, or no-ops), then `git checkout pr-<number>`. If already on `pr-<number>`, use `git merge --ff-only FETCH_HEAD` instead — git refuses to fetch into the checked-out branch.
- `git fetch origin <baseRefName>`; the diff range is `origin/<baseRefName>..HEAD`.

### 3. Derive requirements

- Read the PR `title` + `body`; extract the intended behavior / acceptance criteria.
- **Sufficiency check** — the body is sufficient only if it states what the change should *do*: observable behavior, scope, or linked acceptance criteria. A bare title, "WIP", or an unfilled template is **not** sufficient.
- If insufficient → ask via `AskUserQuestion` before proceeding. Never infer scope from the diff alone.

### 4. Gate (parallel)

Dispatch everything from **this (main) loop** in **one message** (see the nesting rule in
`references/passes.md`). On a re-run, dispatch only what **Re-runs** selects.

- **Completeness** — one `Agent` call following `references/completeness.md` against the derived requirements.
- **Review — Stage 1** — the specialized passes from `references/passes.md` as individual `Agent`
  calls in this same message (`code-quality-reviewer`, `security-scanner`, `code-explorer`, and
  `database-explorer` only when the diff touches persisted data).

Then **Review — Stage 2** per `references/passes.md` (depends on `code-explorer`).

### 5. Provenance (hard step — before the verdict)

Run **Provenance and citations** from `references/passes.md` on **every** finding. No finding
enters the verdict unblamed.

Combine completeness + the surviving review findings into one verdict using `references/templates.md`.

## Feature mode

No checkout (already on the feature branch). Dispatch using the **same topology as §4–§5**, with two deltas: completeness runs `references/completeness.md` against the **Definition of Done / Observable Truths** in `.planning/STATE.md`, and the diff range is `origin/main..HEAD`.

## Combined verdict

- **READY** — completeness is **PASS** *and* review has no Blocking findings (see Severity in `references/templates.md`).
- **BLOCKED** — anything else. List exactly what blocks, each with `file:line`.

Non-blocking and Optional findings **never** block and **never** require another gate run.

## Triage

After the verdict, put every **Non-blocking** and **Optional** finding in the **Triage** table in
`references/templates.md`. Copy the assessment from the pass; do not re-word it into something
stronger. The recommendation is one of:

- **Fix now** — concrete impact on this change, *and* a local fix (doc, test, type) that adds no
  mechanism and has been checked against the repo's written conventions.
- **Follow-up** — real impact, but the fix adds a mechanism, reaches beyond this change's scope, or
  touches older code. Record it where the repo tracks follow-ups (ADR follow-ups, an INDEX, or a
  ticket) — **never as code in this branch**.
- **Ignore** — no concrete impact, already covered, or style the repo does not enforce. Say which.

Each recommendation gets one sentence of reasoning that refers to the **impact**, not to the
reviewer's wording. **Never offer "apply all"**, and never bundle triage items into the blocker fixes.

## Fixing blockers

Applies to whoever fixes after the verdict — this session included.

- Fix the defect at the **smallest scope** that removes it. Do not add a mechanism (transaction,
  error path, cache, outcome, helper) to fix a doc or a test.
- **Before changing behaviour**, find the repo's written rule for that kind of code (where lock waits
  are bounded, which layer catches what, how errors are wrapped) and follow it. If none exists, say so.
- If two fixes touch the **same code path**, reason about how they interact before writing either.

## Pre-regate sweep

For every identifier, log message, alarm level, outcome or status name, and behaviour the fixes changed:

- grep `src/`, `tests/`, `docs/` and planning files (`.planning/`, ADRs) — or the repo's equivalents —
  and read each comment or doc that states the **old** behaviour;
- check renamed symbols have no old references, and no JSDoc/docstring got detached from its
  declaration;
- read the fix diff once as a reviewer would;
- run compile, lint on the changed files, and the relevant tests.

Report the sweep in one line (e.g. `Sweep: 4 terms grepped, 1 stale comment fixed, tsc + eslint +
12 tests green`). **Do not re-gate until it is clean.**

## Convergence guard

- If a re-run's Blocking findings come from code added to address the **previous** run's findings,
  stop before fixing them. Report it to the user as a **process problem**, and propose **reverting**
  that code rather than patching it.
- After **two consecutive BLOCKED** runs, also ask whether the plan itself needs revisiting
  (`/feature` → "When to Go Back").

## Related Skills

- `/verify`, `/review` — thin shims over `references/completeness.md` and `references/passes.md`; invoke them directly for a single dimension.
- `/receiving-review` — after the gate, to address reviewer feedback.
- `/feature` — "When to Go Back", for the convergence guard's plan check.
