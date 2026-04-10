---
name: feature
description: >-
  Implement a feature from a Jira ticket ID (e.g., UN-1234) and an approved plan through test-driven milestones.
  Requires: a Jira ticket ID and an approved plan in .planning/STATE.md.
  Not for: planning (use /plan). Not for: creating tickets (use /jira).
argument-hint: "<JIRA-TICKET-ID>"
allowed-tools: Read, Grep, Glob, Write, Edit, Agent, Skill, Bash(npm *, npx *, node *, git *, make *), TaskCreate, TaskUpdate, TaskList
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`

ultrathink

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
| Jira ticket ID (e.g., `UN-1234`) | Implement a specific ticket | Fetch ticket, locate plan, Steps 1-6 scoped to ticket |
| Anything else (feature name, story, path, none) | Missing ticket | **Stop** — redirect to `/plan` first, then `/jira` to create tickets |

## Feature Types

| Type | Indicators | Strategy |
|------|-----------|----------|
| **Greenfield** | "new feature", "add capability" | Full implementation from scratch |
| **Enhancement** | "improve", "extend", "add to existing" | Incremental change to existing code |
| **Integration** | "connect", "integrate with" | Interface design + compatibility verification |
| **Migration** | "replace", "upgrade" | Parallel implementation + switchover plan |

## Process

### 1. Pre-flight

Parse `$ARGUMENTS` to extract a Jira ticket ID (pattern: `[A-Z]+-\d+`, e.g., `UN-1234`).

**Gate 1 — Jira ticket required:**
If no ticket ID is found in `$ARGUMENTS`:
- Stop. Tell the user: "A Jira ticket ID is required to use `/feature`. Run `/plan` to create an implementation plan, then `/jira` to decompose it into tickets."

**Gate 2 — Branch check:**
If on `main` or `master`:
- Stop. Ask the user to switch to a feature branch or confirm creating one: "You are on `main`. Should I create a feature branch `<TICKET-ID>-<short-description>` from the latest default branch?"

**Fetch & confirm requirements:**
- Fetch ticket details: `acli jira workitem view <TICKET_ID>` — read scope, requirements, and acceptance criteria. If `acli` is unavailable, ask the user to paste the ticket content.
- Present a concise ticket summary to the user:
  - **Title** and **type** (Task/Story/Bug)
  - **Requirements** (what must be built)
  - **Acceptance criteria** (how done is defined)
- Ask the user: "Does this match your understanding? Any clarifications needed before we proceed?"
- Wait for user confirmation before continuing.

**Gate 3 — Plan required:**
- Check if `.planning/STATE.md` exists.
  - If found → load it. Cross-reference the plan's Definition of Done and phases with the ticket's acceptance criteria. Note any mismatches and surface them to the user.
  - If not found → ask the user: "Is there an existing plan file for this work? If so, provide the path."
    - If user provides a path → load that file.
    - If no plan exists → Stop. Tell the user: "An approved plan is required before implementation. Run `/plan` first, then `/jira` to create tickets."

**Branch creation:**
- Create a feature branch from the latest default branch: `<TICKET-ID>-<short-description>` (following `git-conventions.md`)
- Proceed to Step 2.

**Stop conditions:**
- No Jira ticket ID → redirect to `/plan` then `/jira`
- On main/master → confirm branch creation before proceeding
- No plan found → redirect to `/plan`
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
8. Stage and commit: stage specific files by name (`git add <file>`), never `git add .`; commit using the `<TICKET-ID> <type>(<scope>): <subject>` format from `git-conventions.md`

### 5. Verify → Review → Commit → PR

After all milestones are implemented, run the full delivery chain:

#### 5a. Verify

Use the Skill tool to load: `verify` — run full three-level verification against the Definition of Done (ticket acceptance criteria + plan observable truths if available).

**Gate 4 — Verification must pass:**
If `/verify` reports any FAIL, PARTIAL, or CRITICAL anti-pattern findings:
- Stop. Do not proceed to Step 5b (`/review`).
- Debug following `.claude/rules/debug.md` (reproduce → isolate → hypothesize → fix → verify).
- Re-run `/verify` after each fix.
- Only proceed to Step 5b when `/verify` reports all observable truths as PASS with evidence.

#### 5b. Review

Use the Skill tool to load: `review` — perform a quality review of the changes on this branch:
- Code smells, SOLID violations, security issues
- Adherence to existing codebase patterns and conventions
- Address any findings before proceeding to commit

#### 5c. Commit

Stage and commit any fixes made during the review step: stage specific files by name (`git add <file>`), never `git add .`; commit using the `<TICKET-ID> <type>(<scope>): <subject>` format from `git-conventions.md`.

#### 5d. PR

Use the Skill tool to load: `pr` — create a focused draft PR for this ticket's changes.

### 6. Summary

After the full delivery chain completes (verify → review → commit → PR), produce a concise summary:

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
| No Jira ticket ID | Stop — redirect to `/plan` first, then `/jira` to create tickets |
| No plan found | Stop — redirect to `/plan` first, then `/jira` to create tickets |
| Unclear requirements | Stop — redirect to `/plan`; do not clarify requirements here |
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
| `/pr` | Runs automatically after commit as part of the delivery chain |
| `/confluence` | Reference Confluence specs or publish feature documentation |
