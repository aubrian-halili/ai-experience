---
name: feature
description: >-
  User asks to "implement this feature", "build this", "start coding",
  "implement this ticket", or is ready to write code. Use after /plan for complex features.
  Not for: still deciding on approach (use /plan).
argument-hint: "[feature name or description]"
allowed-tools: Read, Grep, Glob, Write, Edit, Agent, Bash, TaskCreate, TaskUpdate, TaskList
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`

Guide structured feature development from specification through incremental implementation with clear milestones and verification steps.

## Development Philosophy

- **Incremental delivery** — ship working slices, not layers; each milestone produces demonstrable value
- **Specification before code** — clarify scope, acceptance criteria, and non-scope before writing implementation
- **User approval gates** — present plans for review before implementation; never proceed on assumptions
- **Test-driven confidence** — write tests first to encode expectations, then implement to satisfy them
- **Scope discipline** — build exactly what's needed; track out-of-scope items explicitly and defer them

## Iron Laws

> - NO implementation before Definition of Done is written
> - NO milestone marked complete without verification evidence
> - Tests-first or delete the code and start over

## Rationalization Guard

| Excuse | Reality |
|--------|---------|
| "Let me write the code first, tests after" | Tests-after is verification theater, not TDD |
| "This milestone is too small to verify" | Small milestones are exactly where verification is cheapest |
| "The plan is in my head" | Unwritten plans drift; observable truths prevent scope creep |
| "I'll track tasks manually" | Manual tracking drops items; use TaskCreate for accountability |

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| Feature name (e.g., `user authentication`) | Develop feature | Determine Feature Type, full Steps 1-7 |
| Feature + scope (e.g., `add OAuth to login`) | Scoped enhancement | Steps 1-7; emphasis on impact analysis (step 2) |
| User story (e.g., `as a user I want...`) | Story-driven development | Extract requirements from story, determine Feature Type, Steps 1-7 |
| File path / directory (e.g., `src/auth/`) | Module-scoped feature | Steps 1-7; analyze existing module first (step 2) |
| (none) | Ask user | Pre-flight stop |

## Feature Types

| Type | Indicators | Strategy |
|------|-----------|----------|
| **Greenfield** | "new feature", "add capability" | Full specification + implementation from scratch |
| **Enhancement** | "improve", "extend", "add to existing" | Impact analysis + incremental change to existing code |
| **Integration** | "connect", "integrate with" | Interface design + compatibility verification |
| **Migration** | "replace", "upgrade" | Parallel implementation + switchover plan |

## Process

### 1. Pre-flight

- Parse `$ARGUMENTS` and map to the appropriate intent (Feature Name, Feature + Scope, User Story, File Path, or Ask User) using the Input Handling table
- **If a Jira ticket ID is referenced** (e.g., `UN-1234`), fetch ticket details using `acli jira workitem view <TICKET_ID>` to pull acceptance criteria, priority, and requirements directly from Jira. If acli is unavailable, proceed with user-provided context and note the limitation.
- Determine the Feature Type (Greenfield, Enhancement, Integration, or Migration) from the Feature Types section above
- Search for related existing features, patterns, and conventions in the codebase
- Check for existing specs or documentation related to the feature

**Stop conditions:**
- On main/master branch → warn user and stop; do not implement without explicit consent to work on main
- Feature already exists → report existing implementation and ask whether to enhance or replace
- Requirements unclear or contradictory → ask clarifying questions before proceeding
- Scope too vague to classify (e.g., "make it better") → ask user to narrow scope

### 2. Explore

- Launch 1-2 Explore agents in parallel to understand the relevant codebase:
  - Agent 1: "Find features similar to [feature] and trace their implementation patterns"
  - Agent 2: "Map the architecture and abstractions relevant to [feature area]"
- Read all key files identified by agents to build deep context
- Present a summary of: existing patterns to follow, code to reuse, integration points, conventions

**Skip when:** Feature scope is narrow and target files are already known from Pre-flight.

### 3. Clarify

**CRITICAL — DO NOT SKIP this step.**

- Review codebase findings and the feature request
- Identify underspecified aspects: edge cases, error handling, integration points, backward compatibility, performance needs
- Present all questions to the user in a clear, organized list
- **Wait for answers before proceeding to design**

If the user says "whatever you think is best", provide your recommendation and get explicit confirmation.

### 4. Specify

- Gather requirements: problem statement, user stories, acceptance criteria, out-of-scope items, and dependencies
- Identify non-functional requirements (performance, security, scalability)
- Analyze the codebase for existing patterns to follow, code to modify vs. create, integration points, and test coverage requirements

### 5. Design & Present

- **Define "Definition of Done"** — before planning milestones, define observable truths that must be TRUE when the feature is complete (see `@references/templates.md` for format)
  - Each truth must be verifiable: a file exists, a test passes, an endpoint responds, a query returns expected data
  - Organize by category: Artifacts, Behavior, Integration, Quality
- Break down into incremental milestones with: goal, tasks, dependencies, and verification criteria
- Each milestone should satisfy specific observable truths from the Definition of Done
- Select a delivery pattern from `@references/templates.md` (Vertical Slice, Horizontal Layer, or Feature Flags)
- **Present the complete plan to the user before proceeding to implementation**
- Show: feature specification, Definition of Done, milestone breakdown, files to create/modify
- If changes requested, revise and present again

### 6. Implement

**Only proceed after user approval of the plan.**

After approval, convert the plan into tracked tasks:
- Create a task for each milestone using `TaskCreate` with clear subject and description
- Set task dependencies using `addBlockedBy` where phases depend on prior phases
- Update each task to `in_progress` when starting and `completed` when verified

For each milestone:
1. Mark the milestone task as `in_progress` via `TaskUpdate`
2. Write test encoding the acceptance criterion
3. Run the test — confirm it FAILS (if it passes, investigate: test may be wrong or feature may already exist)
4. Implement minimum viable code to pass the test
5. Run the test — confirm it PASSES (and no other tests broke)
6. Refactor if needed (tests must remain green)
7. Mark the milestone task as `completed` via `TaskUpdate`
8. Commit with clear message following project conventions

### 7. Verify

Perform three-level verification against the Definition of Done:

**Level 1 — Existence:** Confirm all planned artifacts exist (files, exports, tests, configs, migrations).

**Level 2 — Substance:** Verify implementations are real, not stubs. Scan for anti-patterns:
- TODO/FIXME comments in new code
- Stub returns (`return null`, `return {}`, `throw new Error('TODO')`)
- Empty catch blocks or console-only error handling
- Placeholder configuration values

**Level 3 — Wiring:** Verify all artifacts are connected:
- Exports are imported where needed
- Routes/handlers are registered
- Middleware is applied to correct paths
- Tests are included in test runner scope

**Final checks:**
- Confirm all observable truths from the Definition of Done are satisfied
- Verify all tests pass and cover key behaviors
- Check that implementation follows existing codebase patterns identified in Pre-flight
- Note any deferred items or out-of-scope work for follow-up
- If feature warrants it, recommend `/review` for formal code review or `/verify` for comprehensive completeness check
- Apply verification discipline: no completion claim without fresh evidence — all observable truths must be re-checked, not assumed

## Output Principles

- **Plan before code** — always present the feature specification and milestone breakdown for user review before writing any implementation
- **Milestone-driven progress** — each milestone produces a working, verifiable increment; never deliver untestable intermediate states
- **Explicit scope boundaries** — clearly state what is in-scope, out-of-scope, and deferred; surface any scope creep immediately
- **Test-first verification** — every acceptance criterion maps to a test; untested criteria are not verified

## Error Handling

| Scenario | Response |
|----------|----------|
| Unclear requirements | Ask clarifying questions before planning |
| Large scope | Recommend breaking into multiple features |
| Missing dependencies | Identify blockers, suggest sequencing |
| Conflicting requirements | Surface trade-offs, request decision |
| Partial implementation blocked | Complete what is possible, mark blocked items with `[Blocked]`, report status |
| Test failures during implementation | Stop, report failing tests, do not proceed to next milestone |
| Existing feature overlap | Report the overlap, ask whether to extend existing or create new |

Never silently skip milestones or acceptance criteria—surface gaps and blockers explicitly.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Feature implementation needs code review |
| `/plan` | Need to decompose a large goal before feature implementation |
| `/verify` | Need comprehensive post-implementation verification |
