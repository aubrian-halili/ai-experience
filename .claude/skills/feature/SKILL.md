---
name: feature
description: >-
  User asks to "implement this feature", "build this", "start coding",
  "implement this ticket", provides a Jira ticket ID (e.g., UN-1234), or is ready to write code.
  Not for: still deciding on approach (use /plan). Not for: implementing 3+ independent modules in parallel (use /subagent-driven-development).
argument-hint: "[feature name or description]"
allowed-tools: Read, Grep, Glob, Write, Edit, Agent, Skill, Bash(npm *, npx *, node *, git *, make *), TaskCreate, TaskUpdate, TaskList
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`

Execute structured feature implementation from an approved plan through incremental, test-driven milestones with clear verification at each step.

## Development Philosophy

- **Plan-first** — exploration, clarification, and architecture design happen in `/plan`; this skill implements
- **Incremental delivery** — ship working slices, not layers; each milestone produces demonstrable value
- **User approval gates** — present the implementation plan for review before writing any code
- **Test-driven confidence** — write tests first to encode expectations, then implement to satisfy them
- **Scope discipline** — build exactly what's needed; track out-of-scope items explicitly and defer them

## Iron Laws

> - NO implementation before Definition of Done is confirmed from the plan
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
| Jira ticket ID (e.g., `UN-1234`) | Implement a specific ticket | Fetch ticket from Jira, ask for plan, Steps 1-6 scoped to ticket |
| Feature name (e.g., `user authentication`) | Implement feature | Ask for plan; full Steps 1-6 |
| Feature + scope (e.g., `add OAuth to login`) | Scoped enhancement | Ask for plan; Steps 1-6 with plan context |
| User story (e.g., `as a user I want...`) | Story-driven development | Ask for plan; load plan matching the story |
| File path / directory (e.g., `src/auth/`) | Module-scoped feature | Ask for plan; Steps 1-6 with module context |
| (none) | Ask user | Pre-flight stop |

## Feature Types

| Type | Indicators | Strategy |
|------|-----------|----------|
| **Greenfield** | "new feature", "add capability" | Full implementation from scratch |
| **Enhancement** | "improve", "extend", "add to existing" | Incremental change to existing code |
| **Integration** | "connect", "integrate with" | Interface design + compatibility verification |
| **Migration** | "replace", "upgrade" | Parallel implementation + switchover plan |

## Process

### 1. Pre-flight

- Parse `$ARGUMENTS` and map to the appropriate intent using the Input Handling table

**If a Jira ticket ID is provided** (e.g., `UN-1234`):
- Fetch ticket details using `acli jira workitem view <TICKET_ID>` to read scope, requirements, and acceptance criteria. If acli is unavailable, ask the user to paste the ticket content.
- Ask the user: "Is there a plan file for this work? (e.g., `.planning/STATE.md`)" — if yes, load it for architecture context and dependency awareness; if no, proceed using the ticket alone as the source of truth.
- Create a feature branch from the latest default branch: `<TICKET-ID>-<short-description>` (following git-conventions.md)
- Proceed to Step 2 with ticket content as the Definition of Done

**If a feature name or description is provided** (no ticket ID):
- Ask the user: "Is there a plan file for this work? (e.g., `.planning/STATE.md`)" — if yes, load it; if no, redirect to `/plan` first.
- Proceed to Step 2 with plan content as the Definition of Done

**Stop conditions:**
- No ticket ID and no plan found → redirect to `/plan`
- On main/master branch with no ticket ID → ask user for Jira ticket ID before creating a branch
- Feature already exists → report existing implementation and ask whether to enhance or replace

### 2. Load Plan

- Read `.planning/STATE.md` to understand current progress and any completed phases
- Read the plan's Definition of Done, chosen architecture, and phase breakdown
- If resuming mid-implementation, identify the current phase and pick up from there
- Present a brief summary: what's being implemented, chosen architecture approach, phases remaining

### 3. Design & Present

- Using the plan's architecture choice and observable truths as the foundation:
  - Break down each plan phase into incremental milestones with: goal, tasks, dependencies, and verification criteria
  - Each milestone should satisfy specific observable truths from the plan's Definition of Done
  - Select a delivery pattern from `@references/templates.md` (Vertical Slice, Horizontal Layer, or Feature Flags)
  - Show: milestone breakdown, files to create/modify, delivery pattern rationale
- **Present the complete implementation plan to the user before proceeding**
- If changes requested, revise and present again

### 4. Implement

**Only proceed after user approval of the implementation plan.**

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
8. Use the Skill tool to load: `commit` — then commit with a message following project conventions

### 5. Verify → Review → Commit → PR → Finish

After all milestones are implemented, run the full delivery chain:

#### 5a. Verify

Use the Skill tool to load: `verify` — then perform three-level verification against the Definition of Done (ticket acceptance criteria + plan observable truths if available):

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

**Debug gate — do not proceed until `/verify` fully passes:**
If `/verify` finds failures (missing artifacts, stubs, wiring gaps, or test failures):
1. Stop — do not proceed to `/review` or `/commit`
2. Debug following the process in `.claude/rules/debug.md`: reproduce → isolate → hypothesize → fix → verify
3. Re-run `/verify` after each fix until all checks pass

#### 5b. Review

Use the Skill tool to load: `review` — perform a quality review of the changes on this branch:
- Code smells, SOLID violations, security issues
- Adherence to existing codebase patterns and conventions
- Address any findings before proceeding to commit

#### 5c. Commit

Use the Skill tool to load: `commit` — commit all changes with a message referencing the ticket ID.

#### 5d. PR

Use the Skill tool to load: `pr` — create a focused draft PR for this ticket's changes.

#### 5e. Finish

Use the Skill tool to load: `finish` — clean up the branch, transition the Jira ticket status, and wrap up.

### 6. Summary

After the full delivery chain completes (verify → review → commit → PR → finish), produce a concise summary:

- **What was built**: one-paragraph description of the ticket's scope
- **Key decisions**: architectural choices made and why
- **Files created/modified**: table of all files touched with their purpose
- **Acceptance criteria satisfied**: final checklist against the ticket's acceptance criteria
- **Deferred items**: anything explicitly out-of-scope or flagged during implementation
- **PR**: link to the created pull request

Update `.planning/STATE.md` marking this ticket as complete with a timestamp and PR link.
Mark all tracked tasks as `completed` via `TaskUpdate`.

## Output Principles

- **Plan before code** — always present the milestone breakdown for user review before writing any implementation
- **Milestone-driven progress** — each milestone produces a working, verifiable increment; never deliver untestable intermediate states
- **Explicit scope boundaries** — clearly state what is in-scope, out-of-scope, and deferred; surface any scope creep immediately
- **Test-first verification** — every acceptance criterion maps to a test; untested criteria are not verified

## Error Handling

| Scenario | Response |
|----------|----------|
| No plan found | Redirect to `/plan` before proceeding |
| Unclear requirements | Ask `/plan` to be run first; do not clarify requirements here |
| Large scope | Recommend breaking into multiple features, each with their own plan |
| Missing dependencies | Identify blockers, suggest sequencing |
| Conflicting requirements | Surface trade-offs, request decision |
| Partial implementation blocked | Complete what is possible, mark blocked items with `[Blocked]`, report status |
| Test failures during implementation | Stop, report failing tests, do not proceed to next milestone |
| Existing feature overlap | Report the overlap, ask whether to extend existing or create new |

Never silently skip milestones or acceptance criteria — surface gaps and blockers explicitly.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/plan` | Need to explore, clarify, and design before implementation |
| `/jira` | Decompose plan into tickets before starting implementation |
| `/verify` | Runs automatically after implementation as part of the delivery chain |
| `/review` | Runs automatically after `/verify` as part of the delivery chain |
| `/commit` | Runs automatically after `/review` as part of the delivery chain |
| `/pr` | Runs automatically after `/commit` as part of the delivery chain |
| `/finish` | Runs automatically after `/pr` as part of the delivery chain |
| `/subagent-driven-development` | Parallelize implementation when feature has 3+ independent tasks |
| `/confluence` | Reference Confluence specs or publish feature documentation |
