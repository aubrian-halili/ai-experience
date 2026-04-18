---
name: plan
description: >-
  User asks to "plan", "break down", "decompose", "scope this work",
  "compare approaches", "trade-offs", "pros and cons", "brainstorm",
  or references a Jira epic needing implementation steps. Use before /feature.
  Not for: implementing directly (use /feature).
  Not for: creating or managing Jira tickets (use /jira).
argument-hint: "[goal, epic, Jira ticket, or feature description]"
allowed-tools: Read, Grep, Glob, Write(.planning/STATE.md), Edit(.planning/STATE.md), Agent, Skill, TaskCreate, TaskUpdate, TaskList, Bash(acli *)
disable-model-invocation: true
---

## Process

> **Planning artifact exemption:** `.planning/STATE.md` is a planning artifact. This skill always creates and edits it — including when Claude Code is in plan mode. Treat it exactly like the plan file itself.

> **Small-scope gate:** When scope is ≤3 files with no new integration points, skip §2 and §3 and default to Pragmatic Balance.

### 1. Pre-flight

1. **If a Jira ticket ID is found in `$ARGUMENTS`**: fetch it via `acli jira workitem view <TICKET_ID>`.
2. **Check for existing `.planning/STATE.md`** — if found, ask the user a binary choice: **resume** or **start over**.
   - **resume** → continue from the phase marked current
   - **start over** → back up the existing file with a descriptive name derived from the goal, then proceed with a new plan
3. **Create `.planning/STATE.md`** from the Session State Template in `@references/templates.md`, filling the Plan section (DoD + Phase Breakdown).

### 2. Codebase Research

Launch `code-explorer` with the goal as its topic. Also launch `database-explorer` in parallel (with a research question derived from the goal) if any of these hold: the goal names a table or domain entity; the Jira body contains "migration", "schema", or "model"; or `code-explorer` returns files under `*/migrations/*`, `*/models/*`, or ORM schema paths.

Pass both the **Essential Files** list from `code-explorer` and the **Essential Tables** list from `database-explorer` (when present) into every `code-architect` agent in §3.

### 3. Architecture Comparison

Launch 2-3 `code-architect` agents in parallel, each with a different focus:
- **Minimal Changes** (include for Medium+ complexity)
- **Clean Architecture**
- **Pragmatic Balance**

Present results using the Architecture Comparison Template.

### 4. Track State

Finalize `.planning/STATE.md`. Complete the Plan section with the full phase breakdown (files, verification per phase) and confirm every observable truth in the Definition of Done maps to at least one phase. Update the State section's Progress table to reflect all phases.

Convert phases into tracked tasks:
- `TaskCreate` per phase with goal as subject and observable truths as description
- Set `addBlockedBy` dependencies matching the phase dependency graph

**If the plan originated from a Jira ticket:** prompt the user to continue with `/feature <TICKET-ID>`.
