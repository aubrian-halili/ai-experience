---
name: feature
description: >-
  Implement a Jira ticket (e.g., "implement UN-1234", "build the feature", "work on <TICKET>")
  through test-driven milestones, then automatically run /verify → /review → /pr.
  Requires both a Jira ticket ID and an approved plan in .planning/STATE.md; offers to branch off main if needed.
  Not for: planning (use /plan); not for: creating tickets (use /jira).
argument-hint: "<JIRA-TICKET-ID>"
allowed-tools: Read, Grep, Glob, Write, Edit, Agent, Skill, Bash(npm *, npx *, node *, git *, make *), TaskCreate, TaskUpdate, TaskList
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`

## Process

### 1. Pre-flight

Parse `$ARGUMENTS` to extract a Jira ticket ID (e.g., `UN-1234`).

**Gate 1 — Jira ticket required:**
If no ticket ID is found in `$ARGUMENTS`:
- Stop. Tell the user: "A Jira ticket ID is required to use `/feature`. Run `/plan` to create an implementation plan, then `/jira` to decompose it into tickets."

**Gate 2 — Branch check:**
If on `main` or `master`, offer to create a feature branch per git conventions.

**Fetch & confirm requirements:**
- Fetch ticket details: `acli jira workitem view <TICKET_ID>` — read scope, requirements, and acceptance criteria.
- Confirm scope with the user before continuing.

**Gate 3 — Plan required:**
- Check if `.planning/STATE.md` exists.
  - If found → load it. Cross-reference the plan's Definition of Done and phases with the ticket's acceptance criteria. Note any mismatches and surface them to the user.
  - If not found → ask the user: "Is there an existing plan file for this work? If so, provide the path."
    - If user provides a path → load that file.
    - If no plan exists → Stop. Tell the user: "An approved plan is required before implementation. Run `/plan` first, then `/jira` to create tickets."

### 2. Design & Present

- Break down each plan phase into incremental milestones using `@references/templates.md`.
  - Select a delivery pattern from the template

### 3. Implement

- Create a task per milestone with `TaskCreate`
- Set task dependencies using `addBlockedBy` where phases depend on prior phases

For each milestone:
- **Independent milestones** — dispatch an `implementation-worker` agent with explicit file scope, goal, and acceptance criteria. Collect results before merging.
  - Worker brief must include: **surgical constraint** — "change only lines required by this milestone's acceptance criteria; do not refactor, reformat, or clean up adjacent code; if orphaned imports/vars result from your change, remove them, but leave pre-existing dead code alone."
- **Sequential milestones** — implement inline, in order.

### 4. Verify → Review → Commit → PR

Run `/verify` → `/review` → `/commit` → `/pr`.

### 5. Record completion

After the full delivery chain completes, update `.planning/STATE.md` marking this ticket as complete with a timestamp and PR link.

