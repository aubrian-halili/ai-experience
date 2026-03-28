---
name: feature
description: >-
  User asks to "implement this feature", "build this", "start coding",
  "implement this ticket", or is ready to write code. Requires /plan first.
  Not for: still deciding on approach (use /plan).
argument-hint: "[feature name or description]"
allowed-tools: Read, Grep, Glob, Write, Edit, Agent, Bash(npm *, npx *, node *, git *, make *), TaskCreate, TaskUpdate, TaskList
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
| Feature name (e.g., `user authentication`) | Implement feature | Requires plan; full Steps 1-6 |
| Feature + scope (e.g., `add OAuth to login`) | Scoped enhancement | Requires plan; Steps 1-6 with plan context |
| User story (e.g., `as a user I want...`) | Story-driven development | Requires plan; load plan matching the story |
| File path / directory (e.g., `src/auth/`) | Module-scoped feature | Requires plan; Steps 1-6 with module context |
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
- **Check for existing plan**: look for `.planning/STATE.md` in the repo root
  - If no plan exists → stop and redirect: "No plan found. Run `/plan [goal]` to explore the codebase, clarify requirements, and design architecture before implementation."
  - If plan exists → proceed to Step 2
- **If a Jira ticket ID is referenced** (e.g., `UN-1234`), fetch ticket details using `acli jira workitem view <TICKET_ID>` to confirm alignment with the plan. If acli is unavailable, proceed with plan context.
- Determine the Feature Type (Greenfield, Enhancement, Integration, or Migration) from the plan or Input Handling table

**Stop conditions:**
- No plan found → redirect to `/plan`
- On main/master branch → ask user for Jira ticket ID and feature description; create branch following `<JIRA-ID>-<feature-description>` naming from git-conventions.md, then continue
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
8. Commit with clear message following project conventions

### 5. Verify

Perform three-level verification against the Definition of Done from the plan:

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
- Check that implementation follows the architecture chosen in the plan
- Note any deferred items or out-of-scope work for follow-up
- If feature warrants it, recommend `/review` for formal code review or `/verify` for comprehensive completeness check
- Apply verification discipline: no completion claim without fresh evidence — all observable truths must be re-checked, not assumed

### 6. Summary

After verification completes, produce a concise summary:

- **What was built**: one-paragraph description of the feature
- **Key decisions**: architectural choices made and why (reference plan's architecture selection)
- **Files created/modified**: table of all files touched with their purpose
- **Observable truths satisfied**: final checklist status from Definition of Done
- **Deferred items**: anything explicitly out-of-scope or flagged during implementation
- **Recommended next steps**: suggest `/commit`, `/review`, `/pr`, or `/finish` as appropriate

Update `.planning/STATE.md` marking the feature as complete with a timestamp.
Mark all remaining tracked tasks as `completed` via `TaskUpdate`.

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
| `/review` | Feature implementation needs code review |
| `/verify` | Need comprehensive post-implementation verification |
| `/commit` | Commit changes after implementation |
| `/finish` | Wrap up branch after implementation is complete |
| `/confluence` | Reference Confluence specs or publish feature documentation |
