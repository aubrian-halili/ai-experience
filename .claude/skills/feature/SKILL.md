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
If on `main` or `master`, offer to create a feature branch per git conventions.

**Fetch & confirm requirements:**
- Fetch ticket details: `acli jira workitem view <TICKET_ID>` — read scope, requirements, and acceptance criteria. If `acli` is unavailable, ask the user to paste the ticket content.
- Present a concise ticket summary and ask the user to confirm before continuing.

**Gate 3 — Plan required:**
- Check if `.planning/STATE.md` exists.
  - If found → load it. Cross-reference the plan's Definition of Done and phases with the ticket's acceptance criteria. Note any mismatches and surface them to the user. If resuming mid-implementation, identify the current phase and pick up from there.
  - If not found → ask the user: "Is there an existing plan file for this work? If so, provide the path."
    - If user provides a path → load that file.
    - If no plan exists → Stop. Tell the user: "An approved plan is required before implementation. Run `/plan` first, then `/jira` to create tickets."

### 2. Design & Present

- Using the plan's architecture choice and observable truths as the foundation:
  - Break down each plan phase into incremental milestones with: goal, tasks, dependencies, and verification criteria tied to the plan's observable truths
  - Select a delivery pattern from `@references/templates.md` (Vertical Slice, Horizontal Layer, or Feature Flags)
  - Show: milestone breakdown, files to create/modify, delivery pattern rationale

### 3. Implement

After approval, convert the plan into tracked tasks:
- Create a task per milestone with `TaskCreate`
- Set task dependencies using `addBlockedBy` where phases depend on prior phases

For each milestone, implement and commit.

### 4. Verify → Review → Commit → PR

After all milestones are implemented, run the full delivery chain:

#### 4a. Verify

Run `/verify` — full three-level verification against the Definition of Done (ticket acceptance criteria + plan observable truths if available). Re-run until green.

#### 4b. Review

Run `/review`.

#### 4c. PR

Run `/pr`.

### 5. Summary

After the full delivery chain completes, update `.planning/STATE.md` marking this ticket as complete with a timestamp and PR link.

