---
name: plan
description: >-
  User asks to "plan", "break down", "decompose", "scope this work",
  "compare approaches", "trade-offs", "pros and cons", "brainstorm",
  or references a Jira epic needing implementation steps. Use before /feature.
  Not for: implementing directly (use /feature).
argument-hint: "[goal, epic, Jira ticket, or feature description]"
allowed-tools: Read, Grep, Glob, Write, TaskCreate, TaskUpdate, TaskList, Bash(acli *)
disable-model-invocation: true
---

Decompose goals, epics, or Jira tickets into structured implementation phases with clear deliverables, using goal-backward verification to ensure every phase contributes to observable outcomes.

## Planning Philosophy

- **Goal-backward verification** — start from the desired end state and work backward; define "what must be TRUE when done" before planning how to get there
- **Observable truths over vague milestones** — every phase defines concrete, verifiable conditions (file exists, test passes, endpoint responds) not subjective assessments
- **Minimal viable phases** — each phase produces a working increment; never plan a phase that leaves the system in a broken state
- **Explicit dependencies** — surface what blocks what; never assume implicit ordering
- **Plan is a living document** — plans evolve; track state in `.planning/STATE.md` for session continuity

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| Goal description (e.g., `add user authentication`) | Decompose goal | Full Steps 1-5 |
| Jira ticket ID (e.g., `UN-1234`) | Plan from ticket | Fetch ticket via `/jira`, then Steps 1-5 |
| Epic description (e.g., `payment processing system`) | Multi-feature roadmap | Steps 1-5; emphasis on phase dependencies |
| `"overview"` / `"map"` / `"codebase"` | Codebase context for planning | Gather codebase context, then Steps 1-5 |
| `"resume"` / `"continue"` | Resume from state file | Read `.planning/STATE.md`, pick up from current phase |
| Direction unclear (e.g., `how should we handle auth?`) | Explore options first | Diverge-then-converge: generate 2-3 options with trade-offs, then plan the chosen direction |
| (none) | Ask user | Pre-flight stop |

## Process

### 1. Pre-flight

- Parse `$ARGUMENTS` and map to the appropriate intent using the Input Handling table
- **If a Jira ticket ID is referenced** (e.g., `UN-1234`), fetch ticket details using `acli jira workitem view <TICKET_ID>` to ground the plan in actual requirements, acceptance criteria, and priority from Jira. If acli is unavailable, proceed with user-provided context and note the limitation.
- Search the codebase for related existing code, patterns, and conventions
- Check for existing `.planning/STATE.md` — if found, ask whether to resume or start fresh

**Stop conditions:**
- Goal is too vague to decompose (e.g., "make it better") → ask user to narrow scope
- Existing plan found → ask whether to resume, revise, or replace

### 2. Define Done (Goal-Backward Verification)

This is the critical step that prevents "building the wrong thing correctly."

- Define **observable truths** — concrete conditions that must be TRUE when the goal is complete
- Each truth must be verifiable: a file exists, a test passes, an endpoint responds, a query returns expected data
- Organize truths by category: artifacts (files/code), behavior (runtime), integration (wiring), quality (tests/patterns)

**Observable Truth format:**
```
- [ ] [Category] [Specific verifiable condition]
  Example: [Artifact] `src/auth/middleware.ts` exists and exports `authMiddleware`
  Example: [Behavior] POST /api/login returns 200 with valid credentials and 401 with invalid
  Example: [Integration] Auth middleware is applied to all /api/protected/* routes
  Example: [Quality] All auth endpoints have integration tests with >80% coverage
```

- Present observable truths to the user for validation before proceeding
- If the user modifies truths, update and re-validate

### 3. Decompose into Phases

**Scope check:** If the work spans multiple independent subsystems, split into separate plans — each plan should produce independently testable software. A plan that requires coordinating 4+ unrelated modules is a sign it needs splitting.

**File Structure Guidance:**
- Each new file should have a single clear responsibility
- Prefer smaller focused files over monolithic ones
- Group files that change together by responsibility, not by technical layer
- When modifying existing code, follow the established codebase patterns
- If a planned file would hold multiple unrelated concerns, split it

- Work backward from the observable truths to identify required phases
- Each phase must have:
  - **Goal**: what this phase achieves (one sentence)
  - **Observable truths**: subset of truths from Step 2 that this phase satisfies
  - **Files to create/modify**: specific paths
  - **Dependencies**: which phases must complete first
  - **Verification**: how to confirm the phase is done (commands to run, conditions to check)

- Order phases by dependency graph, not intuition
- Each phase should leave the system in a working state

**Task Granularity:**
- Tasks should decompose into the smallest independently-verifiable steps (2-5 minutes each)
- Each step should specify: exact file path, what to write/modify, verification command with expected output
- A fresh agent should be able to complete any single step with only the step description as context
- If a task requires reading more than 5 files to understand the scope, it's too broad — split it
- Map out the file structure before listing implementation steps: every file to create or modify with its purpose

### 3.5 Plan Review (Self-Check)

Before presenting the plan, validate it against the checklist in `@references/plan-reviewer-prompt.md`:
- No TODO markers or placeholder text in any task
- No steps that say "similar to X" without spelling out the actual content
- Every task has specific file paths, not vague references
- Every phase has a verification section with runnable commands
- No file is planned to hold multiple unrelated responsibilities
- Plan is under 1000 lines (split into phases/documents if larger)

If any check fails, revise the plan before proceeding. For large plans (5+ phases), consider dispatching this as a subagent review for more rigorous validation.

### 4. Present Plan

- Present the complete plan to the user using the template from `@references/templates.md`
- Include: goal summary, observable truths, phase breakdown, dependency graph, risk assessment
- If changes requested, revise and present again
- **Do not proceed to state tracking without user approval**

### 5. Track State

- Create or update `.planning/STATE.md` using the template from `@references/templates.md`
- Record: current phase, completed phases, active blockers, key decisions, next steps
- This file enables session continuity — another session can read it and pick up where this one left off

After user approves the plan, convert phases into tracked tasks:
- Create a task for each phase using `TaskCreate` with the phase goal as subject and observable truths as description
- Set dependencies between tasks using `addBlockedBy` matching the phase dependency graph
- As phases are implemented (via `/feature` or direct work), update task status via `TaskUpdate`
- Use `TaskList` to check progress across sessions

## Output Principles

- **Truths before tasks** — always define observable end-state truths before breaking into phases
- **Verifiable phases** — every phase includes specific verification steps, not just "check that it works"
- **Dependency clarity** — explicitly state what blocks what; use a dependency list or diagram
- **Session continuity** — always write `.planning/STATE.md` so work can resume across sessions

## Error Handling

| Scenario | Response |
|----------|----------|
| Goal too vague | Ask clarifying questions to narrow scope |
| Conflicting requirements | Surface trade-offs, request decision |
| Missing codebase context | Search the codebase to gather context before planning |
| Existing plan conflicts | Present differences, ask user to choose |
| Dependencies circular | Flag the cycle, suggest restructuring |
| Scope too large | Recommend breaking into multiple plans or epics |

Never silently skip requirements or assume priorities — surface gaps and trade-offs explicitly.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/feature` | Plan is approved and ready for implementation |
| `/verify` | Plan is implemented and needs verification |
| `/jira` | Need to fetch or update Jira ticket details |
| `/subagent-driven-development` | Parallelize implementation when plan has 3+ independent tasks |
