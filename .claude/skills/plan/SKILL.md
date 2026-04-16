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

**Current branch:** !`git branch --show-current`

ultrathink

Decompose goals, epics, or Jira tickets into structured implementation phases using goal-backward verification, architecture comparison, and persistent state tracking.

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| Goal description (e.g., `add user authentication`) | Decompose goal | Full Steps 1-5 |
| Jira ticket ID (e.g., `UN-1234`) | Plan from ticket | Fetch ticket via `acli`, then Steps 1-5. Record ticket ID in plan. At end, prompt user to continue with `/feature <TICKET-ID>` |
| Goal + Jira ticket ID | Scoped plan from ticket | Fetch ticket, use goal as additional context, Steps 1-5. Record ticket ID. At end, prompt `/feature <TICKET-ID>` |

> **Note:** Resuming an in-progress plan requires no special argument. If `.planning/STATE.md` exists, the skill automatically prompts **resume** or **start over** before proceeding.

## Process

### 1. Pre-flight

1. **Parse `$ARGUMENTS`** — extract any Jira ticket ID (pattern: `[A-Z]+-\d+`) and/or goal description.
2. **If a Jira ticket ID is found**: fetch it via `acli jira workitem view <TICKET_ID>`. Extract scope, requirements, and acceptance criteria.
3. **Check for existing `.planning/STATE.md`** — if found, **automatically** ask the user a binary choice: **resume** or **start over**.
   - **resume** → read the file, skip completed phases, continue from the phase marked current
   - **start over** → back up the existing file first, then proceed with a new plan:
     1. Derive a short description from the existing file's `**Goal**:` line — kebab-case, strip stop-words, truncate to ≤40 chars → `STATE-<short-description>.md` (e.g. `STATE-login-implementation.md`)
     2. If `**Goal**:` is missing or empty → fallback to `STATE-<YYYYMMDD-HHMM>.md`
     3. If `.planning/<backup-name>` already exists → append `-<YYYYMMDD>` before `.md` to avoid overwrite
     4. Rename `.planning/STATE.md` → `.planning/<backup-name>`, then continue
4. **Create `.planning/STATE.md` skeleton now** — do this before proceeding to Step 2, before Definition of Done, before anything else. Write the skeleton using the Session State Template from `@references/templates.md` with: Goal, Source, Created date, Last Updated, and empty sections for Definition of Done / Progress / Current Phase. This ensures session continuity even if planning is interrupted at any later step.

**Stop conditions:**
- Goal too vague and no Jira ticket → ask user to narrow scope or provide a ticket ID

**Vague goal test** — a goal is too vague if it fails ANY of these:
- Names a specific system, feature, component, or endpoint (not "improve the app")
- Implies a verifiable outcome — something that can be tested or observed when done
- Scopes to a bounded area of the codebase (not "make everything better" or "clean things up")

### 2. Define Done (Goal-Backward Verification)

Define **observable truths** — concrete conditions that must be TRUE when the goal is complete. Each truth must be verifiable: a file exists, a test passes, an endpoint responds, a query returns expected data. See `@references/templates.md` for examples by category.

### 3. Architecture Comparison

Launch 2-3 `code-architect` agents in parallel, each with a different focus:
- **Minimal Changes** — smallest possible diff, reuse existing abstractions
- **Clean Architecture** — proper separation of concerns, SOLID principles
- **Pragmatic Balance** — follow existing conventions (include for Medium+ complexity)

**Skip when:** Scope is ≤3 files with no new integration points. Default to Pragmatic Balance.

### 4. Decompose into Phases

Work backward from the observable truths using the chosen architecture. Structure each phase per the Project Plan Template in `@references/templates.md`.

Validate the plan against `@references/plan-reviewer-prompt.md` before presenting.

### 5. Track State

Finalize `.planning/STATE.md` (first written as a skeleton in Step 1) using the template from `@references/templates.md`. This step adds the full phase breakdown and reconciles the Progress table.

**Progressive update rule**: after each planning step completes, append its output to `.planning/STATE.md` and bump `Last Updated`. Step 5 verifies all sections are present and finalizes the Progress table.

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
