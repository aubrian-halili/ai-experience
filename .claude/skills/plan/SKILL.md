---
name: plan
description: >-
  User asks to "plan", "break down", "decompose", "scope this work",
  "compare approaches", "trade-offs", "pros and cons", "brainstorm",
  or references a Jira epic needing implementation steps. Use before /feature.
  Not for: implementing directly (use /feature).
  Not for: creating or managing Jira tickets (use /jira).
argument-hint: "[goal, epic, Jira ticket, or feature description]"
allowed-tools: Read, Grep, Glob, Write, Agent, Skill, TaskCreate, TaskUpdate, TaskList, Bash(acli *)
disable-model-invocation: true
---

## Input Handling

When a Jira ticket ID is found in `$ARGUMENTS`: fetch via `acli`, then follow Steps 1-5. Record ticket ID in plan. At end, prompt user to continue with `/feature <TICKET-ID>`.

## Process

> **Planning artifact exemption:** `.planning/STATE.md` is a planning artifact. This skill always creates and edits it — including when Claude Code is in plan mode. Treat it exactly like the plan file itself.

### 1. Pre-flight

1. **If a Jira ticket ID is found in `$ARGUMENTS`**: fetch it via `acli jira workitem view <TICKET_ID>`.
2. **Check for existing `.planning/STATE.md`** — if found, **automatically** ask the user a binary choice: **resume** or **start over**.
   - **resume** → continue from the phase marked current
   - **start over** → back up the existing file with a descriptive name derived from the goal, then proceed with a new plan
3. **Create `.planning/STATE.md` skeleton now** — always. Write the skeleton using the Session State Template in `@references/templates.md`.

### 2. Define Done (Goal-Backward Verification)

Define the Definition of Done per the Project Plan Template.

### 3. Architecture Comparison

Launch 2-3 `code-architect` agents in parallel, each with a different focus:
- **Minimal Changes** (include for Medium+ complexity)
- **Clean Architecture**
- **Pragmatic Balance**

Present results using the Architecture Comparison Template.

**Skip when:** Scope is ≤3 files with no new integration points. Default to Pragmatic Balance.

### 4. Decompose into Phases

Confirm every observable truth in Define Done maps to at least one phase.

### 5. Track State

Finalize `.planning/STATE.md` using the Session State Template. This step adds the full phase breakdown and reconciles the Progress table.

Convert phases into tracked tasks:
- `TaskCreate` per phase with goal as subject and observable truths as description
- Set `addBlockedBy` dependencies matching the phase dependency graph

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/jira` | Decompose approved plan into Jira tickets (when no ticket exists yet) |
| `/feature` | Implement a Jira ticket with an approved plan (`/feature <TICKET-ID>` — requires both ticket and plan) |
| `/verify` | Plan is implemented and needs verification |
| `/confluence` | Reference or publish design docs and specs in Confluence |
| `/qred-repo` | Browse existing repos for research before finalizing the plan |
| `/doc-sync` | Sync docs first so planning has accurate project context |
