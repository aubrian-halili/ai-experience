---
name: plan
description: >-
  User asks to "plan", "break down", "decompose", "scope this work",
  "compare approaches", "trade-offs", "pros and cons", "brainstorm",
  or references a Jira epic needing implementation steps. Use before /feature.
  Not for: implementing directly (use /feature).
  Not for: creating or managing Jira tickets (use /jira).
argument-hint: "[goal, epic, Jira ticket, or feature description]"
allowed-tools: Read, Grep, Glob, Write(.planning/STATE.md), Edit(.planning/STATE.md), Agent, Skill, AskUserQuestion, ExitPlanMode, TaskCreate, TaskUpdate, TaskList, Bash(acli *)
disable-model-invocation: true
---

## Process

> **Small-scope gate:** When scope is ≤3 files with no new integration points, skip §2 and §3 and default to Minimal Changes.

> **Terminal state:** `.planning/STATE.md` is the deliverable. Do not segue into `/feature` after approval. STATE.md and tasks are persisted only after the user exits plan mode.

### 1. Pre-flight

1. **If a Jira ticket ID is found in `$ARGUMENTS`**: fetch it via `acli jira workitem view <TICKET_ID>`.
2. **Check for existing `.planning/STATE.md`**. If found, ask the user a binary choice: **resume** or **start over**.
   - **resume** → continue from the phase marked current
   - **start over** → note the choice in conversation context; **do not** back up or overwrite the file yet
3. **Draft the Plan section** (DoD + Phase Breakdown) using the Session State Template from `@references/templates.md` as structure. Keep this in conversation context only.

### 2. Codebase Research

Launch `code-explorer` with the goal as its topic. Also launch `database-explorer` in parallel (with a research question derived from the goal) if any of these hold: the goal names a table or domain entity; the Jira body contains "migration", "schema", or "model"; or `code-explorer` returns files under `*/migrations/*`, `*/models/*`, or ORM schema paths.

Pass both the **Essential Files** list from `code-explorer` and the **Essential Tables** list from `database-explorer` (when present) into every `code-architect` agent in §3.

### 3. Architecture Comparison

Launch 2-3 `code-architect` agents in parallel, each with a different focus:
- **Minimal Changes** (include for Medium+ complexity)
- **Clean Architecture**
- **Hexagonal** (include when the feature crosses ≥2 external integrations, requires swappable infrastructure, or domain logic is expected to outlive the current stack — skip for CRUD endpoints, scripts, and single-adapter flows)

Present results using the Architecture Comparison Template.

### 4. Plan Review

Present DoD, phases, and chosen architecture, then call `ExitPlanMode` to request approval.

### 5. Persist *(after plan-mode exit)*

1. If "start over" was chosen in §1, back up the prior `.planning/STATE.md` with a goal-derived name.
2. `Write` `.planning/STATE.md` using the drafted Plan section and initialize the State Progress table.
3. `TaskCreate` per phase with the phase goal as subject and observable truths as description; set `addBlockedBy` to match the phase dependency graph.
