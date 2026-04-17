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

ultrathink

Decompose goals, epics, or Jira tickets into structured implementation phases using goal-backward verification, architecture comparison, and persistent state tracking.

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| Goal description (e.g., `add user authentication`) | Decompose goal | Full Steps 1-5 |
| Jira ticket ID (e.g., `UN-1234`) | Plan from ticket | Fetch ticket via `acli`, then Steps 1-5. Record ticket ID in plan. At end, prompt user to continue with `/feature <TICKET-ID>` |
| Goal + Jira ticket ID | Scoped plan from ticket | Fetch ticket, use goal as additional context, Steps 1-5. Record ticket ID. At end, prompt `/feature <TICKET-ID>` |

## Process

> **Planning artifact exemption:** `.planning/STATE.md` is a planning artifact. This skill always creates and edits it — including when Claude Code is in plan mode. Treat it exactly like the plan file itself.

### 1. Pre-flight

1. **If a Jira ticket ID is found in `$ARGUMENTS`**: fetch it via `acli jira workitem view <TICKET_ID>`. Extract scope, requirements, and acceptance criteria.
2. **Check for existing `.planning/STATE.md`** — if found, **automatically** ask the user a binary choice: **resume** or **start over**.
   - **resume** → read the file, skip completed phases, continue from the phase marked current
   - **start over** → back up the existing file with a descriptive name derived from the goal, then proceed with a new plan
3. **Create `.planning/STATE.md` skeleton now** — always. Write the skeleton using the Session State Template from `@references/templates.md`.

**Stop conditions:**
- Goal too vague and no Jira ticket → ask user to narrow scope or provide a ticket ID

**Vague goal test** — a goal is too vague if it fails ANY of these:
- Names a specific system, feature, component, or endpoint
- Implies a verifiable outcome — something that can be tested or observed when done
- Scopes to a bounded area of the codebase

### 2. Define Done (Goal-Backward Verification)

Define the Definition of Done per `@references/templates.md`.

### 3. Architecture Comparison

Launch 2-3 `code-architect` agents in parallel, each with a different focus:
- **Minimal Changes** (include for Medium+ complexity)
- **Clean Architecture**
- **Pragmatic Balance**

Present results using the Architecture Comparison Template from `@references/templates.md` before proceeding.

**Skip when:** Scope is ≤3 files with no new integration points. Default to Pragmatic Balance.

### 4. Decompose into Phases

Structure each phase per the Project Plan Template in `@references/templates.md`.

Before presenting: confirm every observable truth in Define Done maps to at least one phase.

### 5. Track State

Finalize `.planning/STATE.md` using the template from `@references/templates.md`. This step adds the full phase breakdown and reconciles the Progress table.

Convert phases into tracked tasks:
- `TaskCreate` per phase with goal as subject and observable truths as description
- Set `addBlockedBy` dependencies matching the phase dependency graph
- Update task status via `TaskUpdate` as phases complete

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/jira` | Decompose approved plan into Jira tickets (when no ticket exists yet) |
| `/feature` | Implement a Jira ticket with an approved plan (`/feature <TICKET-ID>` — requires both ticket and plan) |
| `/verify` | Plan is implemented and needs verification |
| `/confluence` | Reference or publish design docs and specs in Confluence |
| `/qred-repo` | Browse existing repos for research before finalizing the plan |
| `/doc-sync` | Sync docs first so planning has accurate project context |
