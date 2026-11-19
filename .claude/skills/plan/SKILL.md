---
name: plan
description: >-
  Turns a goal, epic, or Jira ticket into a researched plan of vertical-slice phases, saved to
  .planning/STATE.md for /jira and /feature to pick up. Use to "plan", "break down", "decompose",
  or "scope" work before implementing it.
  Not for: implementing directly (use /feature).
  Not for: creating or managing Jira tickets (use /jira).
argument-hint: "[goal, epic, Jira ticket, or feature description]"
allowed-tools: Read, Grep, Glob, Write(.planning/STATE.md), Write(.planning/STATE-*.md), Edit(.planning/STATE.md), Agent, AskUserQuestion
disable-model-invocation: true
---

## Process

> **Small-scope gate:** Decide after §1, from the goal plus a quick Grep/Glob. When the change clearly touches ≤3 files with no new integration points, skip §2, §3, and §4.1 and record the approach as Minimal Changes. If scope is unclear, do not apply the gate.

> **Terminal state.** `.planning/STATE.md` is the only deliverable. After §5, end the turn — never invoke or auto-chain into `/jira` or `/feature`.

### 1. Pre-flight

1. If `$ARGUMENTS` is empty and the conversation states no goal, ask for one with `AskUserQuestion` before launching any agent.
2. If `$ARGUMENTS` names a Jira ticket or epic, launch `jira-explorer` with the ticket ID(s) and the goal. Its **Acceptance Criteria** and **Scope Boundaries** are the baseline for DoD and Out of Scope — do not restate them from the argument text.
3. If `.planning/STATE.md` exists, ask: **resume** or **start over**.
   - **resume** → load its Plan section as the draft and continue at §4
   - **start over** → do not back up or overwrite it yet (§5 does)
4. Draft the Plan section (DoD, Out of Scope, Phase Breakdown) from the Session State Template in `@references/templates.md`.

### 2. Codebase Research

Launch `code-explorer` with the goal as its topic. In parallel, launch:

- **`database-explorer`** — when the goal names a table or domain entity, the Jira body mentions "migration", "schema", or "model", or `code-explorer` returns files under `*/migrations/*`, `*/models/*`, or ORM schema paths. Do not mention production in its research question unless the user asked for production data — that wording is what moves it off the test database.
- **`git-repos-explorer`** — only when the goal needs grounding outside this repo: another org service, a shared library or contract, or prior art in another repo.
- **`jira-explorer`** — only if §1 did not run it, and research surfaces a ticket or epic or the work plausibly overlaps existing tickets.
- **`aws-explorer`** — only when the goal depends on a deployed environment: a bug or incident in a running service, a named log group / alarm / Lambda / ECS service, or runtime behavior (error rates, latency, a recent deploy). Name the time or incident window in the question when the goal gives one. Record its findings in STATE.md as summaries only — never log lines or customer identifiers.

Hand every §3 `code-architect` the **Essential Files** from `code-explorer`, plus whatever the others returned: **Essential Tables**, **Essential References**, **Acceptance Criteria** / **Scope Boundaries**, **Essential Resources** / **Log Evidence**.

**Before §3, for every agent's report (including §1's `jira-explorer`):**
- `### Needs User Confirmation` → put each item to the user with `AskUserQuestion`. Never pass it to `code-architect` as fact or resolve it yourself.
- `### Tool Failure` → handle per `.claude/rules/tool-reliability.md` via `AskUserQuestion`; on **proceed**, mark the affected facts unverified in the plan.

### 3. Design

Launch **one** `code-architect` with focus **Existing Patterns** — no competing style blueprints by default.

In parallel, add a **Hexagonal** `code-architect` only when the feature crosses ≥2 external integrations, needs swappable infrastructure, or its domain logic is expected to outlive the current stack.

Present the result with the Design Approach Template in `references/templates.md`.

### 4. Plan Review

1. **Resolve open decisions first.** Surface up to 5 judgment calls that research and design left open — starting from §3's Design Forks, then data model, error handling, migration/rollout, boundary placement. Do not invent decisions to reach a count; if none remain, say so. Ask each with `AskUserQuestion`, using 2–3 options, each briefed with the Decision Option Template in `references/templates.md`. Read each option's cited code yourself before writing it up, in your own words — never relay the architect's fork table as-is. Every option carries a `preview` with what changes, affected areas, effort, impact, likelihood, reversibility, `file:line` evidence, and confidence, so the user can compare the options without the text printed before the dialog. If an option cannot be filled in that much detail, research it further before asking. Any fact that §2 marked unverified stays `assumed` under Confidence. Fold the answers into the phases and Key Decisions.
2. **Then present** DoD, Out of Scope, phases, and the design approach, and get the user's approval.

### 5. Persist *(after approval)*

1. If "start over" was chosen, back up the prior file to `.planning/STATE-<goal-slug>-<YYYY-MM-DD>.md`, slugging the prior file's **Goal**.
2. `Write` `.planning/STATE.md`, seeding State Progress with one row per phase: status `Pending`, and a note naming its dependency (`None` or `Phase N-1`). Track progress in STATE.md, not a task-tracking tool.
3. Report the STATE.md path and the phase list.

## When to Go Back

If §3 reveals that research missed a load-bearing integration, constraint, or entity, loop back to §2 and re-launch the relevant explorer before §4.
