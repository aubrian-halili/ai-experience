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
3. **Create `.planning/STATE.md` skeleton** using the Session State Template in `@references/templates.md`. Include the Definition of Done per the Project Plan Template — observable truths that must be TRUE when the goal is complete.

### 2. Codebase Research

Launch 1 `code-explorer` agent with the goal as its topic. Pass its **Essential Files** list (priority table) into every `code-architect` agent in §3 as context — architects should treat those files as the ground truth of the current implementation.

### 3. Architecture Comparison

Launch 2-3 `code-architect` agents in parallel, each with a different focus:
- **Minimal Changes** (include for Medium+ complexity)
- **Clean Architecture**
- **Pragmatic Balance**

Present results using the Architecture Comparison Template.

### 4. Track State

Finalize `.planning/STATE.md` using the Session State Template. Decompose the goal into phases and confirm every observable truth in Definition of Done maps to at least one phase. Add the full phase breakdown and reconcile the Progress table.

Convert phases into tracked tasks:
- `TaskCreate` per phase with goal as subject and observable truths as description
- Set `addBlockedBy` dependencies matching the phase dependency graph

**If the plan originated from a Jira ticket:** prompt the user to continue with `/feature <TICKET-ID>`.
