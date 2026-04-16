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

## Rationalization Guard

| Excuse | Reality |
|--------|---------|
| "The plan is in my head" | Unwritten plans drift; observable truths prevent scope creep |
| "I'll track tasks manually" | Manual tracking drops items; use TaskCreate for accountability |

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
  - If found → load it. Cross-reference the plan's Definition of Done and phases with the ticket's acceptance criteria. Note any mismatches and surface them to the user. If resuming mid-implementation, identify the current phase and pick up from there.
  - If not found → ask the user: "Is there an existing plan file for this work? If so, provide the path."
    - If user provides a path → load that file.
    - If no plan exists → Stop. Tell the user: "An approved plan is required before implementation. Run `/plan` first, then `/jira` to create tickets."

**Branch creation:**
- If not already on a feature branch (Gate 2 confirmed), create one now: `<TICKET-ID>-<short-description>` (per `git-conventions.md`).

### 2. Design & Present

- Using the plan's architecture choice and observable truths as the foundation:
  - Break down each plan phase into incremental milestones with: goal, tasks, dependencies, and verification criteria
  - Each milestone should satisfy specific observable truths from the plan's Definition of Done
  - Select a delivery pattern from `@references/templates.md` (Vertical Slice, Horizontal Layer, or Feature Flags)
  - Show: milestone breakdown, files to create/modify, delivery pattern rationale
- **Present the complete implementation plan to the user before proceeding**
- If changes requested, revise and present again

### 3. Implement

**Only proceed after user approval of the implementation plan.**

After approval, convert the plan into tracked tasks:
- Create a task for each milestone using `TaskCreate` with clear subject and description
- Set task dependencies using `addBlockedBy` where phases depend on prior phases
- Update each task to `in_progress` when starting and `completed` when verified

For each milestone:
1. Mark the milestone task as `in_progress` via `TaskUpdate`
2. Follow the TDD cycle from `testing.md`
3. Mark the milestone task as `completed` via `TaskUpdate`
4. Stage and commit per `git-conventions.md`

### 4. Verify → Review → Commit → PR

After all milestones are implemented, run the full delivery chain:

#### 4a. Verify

Use the Skill tool to load: `verify` — run full three-level verification against the Definition of Done (ticket acceptance criteria + plan observable truths if available).

**Gate 4 — Verification must pass:**
If `/verify` reports any FAIL, PARTIAL, or CRITICAL anti-pattern findings:
- Stop. Do not proceed to Step 4b (`/review`).
- Debug the failures, then re-run `/verify`.
- Only proceed to Step 4b when `/verify` reports all observable truths as PASS with evidence.

#### 4b. Review

Use the Skill tool to load: `review` — perform a quality review of the changes on this branch:
- Code smells, SOLID violations, security issues
- Adherence to existing codebase patterns and conventions
- Address any findings before proceeding to commit

#### 4c. PR

Use the Skill tool to load: `pr` — create a focused draft PR for this ticket's changes.

### 5. Summary

After the full delivery chain completes (verify → review → commit → PR), produce a concise summary:

- **What was built**: one-paragraph description of the ticket's scope
- **Key decisions**: architectural choices made and why
- **Files created/modified**: table of all files touched with their purpose
- **Acceptance criteria satisfied**: final checklist against the ticket's acceptance criteria
- **Deferred items**: anything explicitly out-of-scope or flagged during implementation
- **PR**: link to the created pull request

Update `.planning/STATE.md` marking this ticket as complete with a timestamp and PR link.
Mark all tracked tasks as `completed` via `TaskUpdate`.

## Error Handling

| Scenario | Response |
|----------|----------|
| Partial implementation blocked | Complete what is possible, mark blocked items with `[Blocked]`, report status |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/plan` | Need to explore, clarify, and design before implementation |
| `/jira` | Decompose plan into tickets before starting implementation |
| `/confluence` | Reference Confluence specs or publish feature documentation |
