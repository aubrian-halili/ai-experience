---
name: plan
description: >-
  User asks to "plan", "break down", "decompose", "scope this work",
  "compare approaches", "trade-offs", "pros and cons", "brainstorm",
  or references a Jira epic needing implementation steps. Use before /feature.
  Not for: implementing directly (use /feature).
  Not for: creating or managing Jira tickets (use /jira).
argument-hint: "[goal, epic, Jira ticket, or feature description]"
allowed-tools: Read, Grep, Glob, Write(.planning/STATE.md), Edit(.planning/STATE.md), Agent, Skill, AskUserQuestion, TaskCreate, TaskUpdate, TaskList, Bash(acli *)
disable-model-invocation: true
---

## Process

> **Small-scope gate:** When scope is ≤3 files with no new integration points, skip §2 and §3 and default to Minimal Changes.

> **Terminal state.** `.planning/STATE.md` is the only deliverable. After §5, end the turn. **Never** invoke, suggest-then-run, or auto-chain into `/jira` or `/feature` — the user invokes the next skill explicitly.

### 1. Pre-flight

1. **If a Jira ticket ID is found in `$ARGUMENTS`**: fetch it via `acli jira workitem view <TICKET_ID>`.
2. **Check for existing `.planning/STATE.md`**. If found, ask the user a binary choice: **resume** or **start over**.
   - **resume** → continue from the phase marked current
   - **start over** → **do not** back up or overwrite the file yet (backup happens in §5)
3. **Draft the Plan section** (DoD + Phase Breakdown) using the Session State Template from `@references/templates.md` as structure.

### 2. Codebase Research

Launch `code-explorer` with the goal as its topic. Also launch `database-explorer` in parallel (with a research question derived from the goal) if any of these hold: the goal names a table or domain entity; the Jira body contains "migration", "schema", or "model"; or `code-explorer` returns files under `*/migrations/*`, `*/models/*`, or ORM schema paths.

Launch `git-repos-explorer` in parallel **only when** the goal needs grounding outside this repo: it names another Qred service or repo; it integrates with a shared Qred library or contract; or the relevant prior art is expected to live in another repo rather than locally. Skip it for self-contained, in-repo work — cross-repo search is slower and is unnecessary by default.

Pass the **Essential Files** list from `code-explorer`, the **Essential Tables** list from `database-explorer` (when present), and the **Essential References** list from `git-repos-explorer` (when present) into every `code-architect` agent in §3.

**Tool failure — pause, do not skip.** If any spawned agent returns a `### Tool Failure` report instead of its normal output (e.g. `database-explorer` could not reach Aurora, `git-repos-explorer` could not run `gh`), stop and `AskUserQuestion` with **retry**, **proceed without that grounding** (label the schema/cross-repo facts as unverified in the plan), or **abort** — per `.claude/rules/tool-reliability.md`. Do not proceed to §3 with code as the sole source of truth.

### 3. Architecture Comparison

Launch 2-3 `code-architect` agents in parallel, each with a different focus:
- **Minimal Changes** (include for Medium+ complexity)
- **Clean Architecture**
- **Hexagonal** (include when the feature crosses ≥2 external integrations, requires swappable infrastructure, or domain logic is expected to outlive the current stack — skip for CRUD endpoints, scripts, and single-adapter flows)

Present results using the Architecture Comparison Template.

### 4. Plan Review

Present DoD, phases, and chosen architecture, then ask the user to approve before persisting.

### 5. Persist *(after approval)*

1. If "start over" was chosen in §1, back up the prior `.planning/STATE.md` with a goal-derived name.
2. `Write` `.planning/STATE.md` using the drafted Plan section and initialize the State Progress table.
3. `TaskCreate` per phase with the phase goal as subject and observable truths as description; set `addBlockedBy` to match the phase dependency graph.
4. Report the STATE.md path and the created task list.
