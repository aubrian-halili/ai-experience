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
- Present a concise ticket summary and ask the user to confirm before continuing.

**Gate 3 — Plan required:**
- Check if `.planning/STATE.md` exists.
  - If found → load it. Cross-reference the plan's Definition of Done and phases with the ticket's acceptance criteria. Note any mismatches and surface them to the user. If resuming mid-implementation, identify the current phase and pick up from there.
  - If not found → ask the user: "Is there an existing plan file for this work? If so, provide the path."
    - If user provides a path → load that file.
    - If no plan exists → Stop. Tell the user: "An approved plan is required before implementation. Run `/plan` first, then `/jira` to create tickets."

**Branch creation:**
- If not already on a feature branch (Gate 2 confirmed), create one following branch naming conventions.

### 2. Design & Present

- Using the plan's architecture choice and observable truths as the foundation:
  - Break down each plan phase into incremental milestones with: goal, tasks, dependencies, and verification criteria
  - Each milestone should satisfy specific observable truths from the plan's Definition of Done
  - Select a delivery pattern from `@references/templates.md` (Vertical Slice, Horizontal Layer, or Feature Flags)
  - Show: milestone breakdown, files to create/modify, delivery pattern rationale
- **Present the implementation plan to the user and wait for approval before proceeding.**

### 3. Implement

After approval, convert the plan into tracked tasks:
- Create a task for each milestone using `TaskCreate` with clear subject and description
- Set task dependencies using `addBlockedBy` where phases depend on prior phases

For each milestone:
1. Implement the milestone, then commit
2. Mark the milestone task as `completed` via `TaskUpdate`

### 4. Verify → Review → Commit → PR

After all milestones are implemented, run the full delivery chain:

#### 4a. Verify

Use the Skill tool to load: `verify` — run full three-level verification against the Definition of Done (ticket acceptance criteria + plan observable truths if available).

If `/verify` reports failures, fix them and re-run before proceeding.

#### 4b. Review

Use the Skill tool to load: `review`.

#### 4c. PR

Use the Skill tool to load: `pr` — create a focused draft PR for this ticket's changes.

### 5. Summary

After the full delivery chain completes (verify → review → commit → PR), produce a concise summary of what was built, key decisions, and acceptance criteria satisfied. Update `.planning/STATE.md` marking this ticket as complete with a timestamp and PR link.

