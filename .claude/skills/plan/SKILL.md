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

## Planning Philosophy

- **Goal-backward verification** — define "what must be TRUE when done" before planning how to get there
- **Observable truths over vague milestones** — every phase defines concrete, verifiable conditions (file exists, test passes, endpoint responds)
- **Minimal viable phases** — each phase produces a working increment; never plan a phase that leaves the system in a broken state
- **Plan is a living document** — track state in `.planning/STATE.md` for session continuity

## Rationalization Guard

| Excuse | Reality |
|--------|---------|
| "The scope is clear enough, let's skip architecture comparison" | Architecture shortcuts in planning cause mid-implementation pivots; ≤3 files is the only valid skip condition |
| "We can define the observable truths later" | Observable truths defined after the plan is written are reverse-engineered from the solution, not the goal |
| "The phases are obvious, no need to document them" | Undocumented phases drift under context pressure; write them before proceeding |
| "Let's skip the plan-reviewer checklist, it'll slow us down" | The checklist prevents plans that fail silently in `/feature`; always validate against it |

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| Goal description (e.g., `add user authentication`) | Decompose goal | Full Steps 1-5 |
| Jira ticket ID (e.g., `UN-1234`) | Plan from ticket | Fetch ticket via `acli`, then Steps 1-5. Record ticket ID in plan. At end, prompt user to continue with `/feature <TICKET-ID>` |
| Goal + Jira ticket ID | Scoped plan from ticket | Fetch ticket, use goal as additional context, Steps 1-5. Record ticket ID. At end, prompt `/feature <TICKET-ID>` |
| `"resume"` / `"continue"` | Resume from state file | Read `.planning/STATE.md`, pick up from current phase |
| (none) | Ask user | Pre-flight stop |

## Process

### 1. Pre-flight

- Parse `$ARGUMENTS` — extract any Jira ticket ID (pattern: `[A-Z]+-\d+`) and/or goal description.
- **If a Jira ticket ID is found**: fetch it via `acli jira workitem view <TICKET_ID>`. Extract scope, requirements, and acceptance criteria. If `acli` is unavailable, ask the user to paste the ticket content. Store the ticket ID — it will be recorded in `.planning/STATE.md` and used for the `/feature` hand-off.
- **If only a goal description is provided**: use it as the planning scope.
- **If neither**: ask the user for a goal or Jira ticket ID.
- Check for existing `.planning/STATE.md` — if found, ask whether to resume or start fresh.
- Search the codebase for related existing code, patterns, and conventions.

**Stop conditions:**
- Goal too vague and no Jira ticket → ask user to narrow scope or provide a ticket ID
- Existing plan found → ask whether to resume, revise, or replace
- On main/master branch → note that implementation will require a feature branch

**Vague goal test** — a goal is too vague if it fails ANY of these:
- Names a specific system, feature, component, or endpoint (not "improve the app")
- Implies a verifiable outcome — something that can be tested or observed when done
- Scopes to a bounded area of the codebase (not "make everything better" or "clean things up")

### 2. Define Done (Goal-Backward Verification)

Define **observable truths** — concrete conditions that must be TRUE when the goal is complete. Each truth must be verifiable: a file exists, a test passes, an endpoint responds, a query returns expected data.

```
- [ ] [Artifact] `src/auth/middleware.ts` exists and exports `authMiddleware`
- [ ] [Behavior] POST /api/login returns 200 with valid credentials and 401 with invalid
- [ ] [Integration] Auth middleware applied to all /api/protected/* routes
- [ ] [Quality] All auth endpoints have integration tests with >80% coverage
```

Present observable truths to the user for validation before proceeding. Update if the user modifies them.

### 3. Architecture Comparison

Launch 2-3 `code-architect` agents in parallel, each with a different focus:
- **Minimal Changes** — smallest possible diff, reuse existing abstractions
- **Clean Architecture** — proper separation of concerns, SOLID principles
- **Pragmatic Balance** — follow existing conventions (include for Medium+ complexity)

Present a comparison table and recommend one approach. Wait for user to choose before proceeding.

**Skip when:** Scope is ≤3 files with no new integration points. Default to Pragmatic Balance.

### 4. Decompose into Phases

Work backward from the observable truths using the chosen architecture. Each phase must have:
- **Goal**: one sentence
- **Observable truths**: subset satisfied by this phase
- **Files to create/modify**: specific paths
- **Dependencies**: which phases must complete first
- **Verification**: runnable commands with expected output

Validate the plan against `@references/plan-reviewer-prompt.md` before presenting.

### 5. Track State

Write or update `.planning/STATE.md` using the template from `@references/templates.md`. Record: current phase, completed phases, key decisions, next steps.

**If the plan was sourced from a Jira ticket**: record the ticket ID in the `**Source**` field of `.planning/STATE.md` (e.g., `**Source**: UN-1234`). This allows `/feature` to cross-reference the plan with the ticket.

Convert phases into tracked tasks:
- `TaskCreate` per phase with goal as subject and observable truths as description
- Set `addBlockedBy` dependencies matching the phase dependency graph
- Update task status via `TaskUpdate` as phases complete

### 6. Next Steps

After the plan is written and tasks are tracked, guide the user to the next step in the workflow:

- **If a Jira ticket ID was provided**: prompt the user — "Plan is ready. Run `/feature <TICKET-ID>` to start implementation."
- **If no Jira ticket exists yet**: prompt the user — "Plan is ready. Run `/jira` to decompose this plan into Jira tickets, then `/feature <TICKET-ID>` to implement."

## Output Principles

- **Truths before tasks** — define observable end-state before breaking into phases
- **Verifiable phases** — every phase has runnable verification commands
- **Session continuity** — always write `.planning/STATE.md`

## Error Handling

| Scenario | Response |
|----------|----------|
| Goal too vague | Ask clarifying questions |
| Conflicting requirements | Surface trade-offs, request decision |
| Existing plan conflicts | Present differences, ask user to choose |
| acli unavailable | Ask user to paste ticket content |
| Scope too large | Recommend splitting into multiple plans |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/jira` | Decompose approved plan into Jira tickets (when no ticket exists yet) |
| `/feature` | Implement a Jira ticket with an approved plan (`/feature <TICKET-ID>` — requires both ticket and plan) |
| `/verify` | Plan is implemented and needs verification |
| `/confluence` | Reference or publish design docs and specs in Confluence |
| `/qred-repo` | Browse existing repos for research before finalizing the plan |
| `/doc-sync` | Sync docs first so planning has accurate project context |
