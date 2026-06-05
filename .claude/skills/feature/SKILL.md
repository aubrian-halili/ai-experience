---
name: feature
description: >-
  Implement an approved plan (e.g., "implement the plan", "build the feature", "start working on it")
  through test-driven milestones, then automatically run /verify → /review and stop so the user can inspect the diff before manually running /commit and /pr.
  Requires an approved plan in .planning/STATE.md containing a Jira ticket ID; offers to branch off main if needed.
  Not for: planning (use /plan); not for: creating tickets (use /jira).
allowed-tools: Read, Grep, Glob, Write, Edit, Agent, Skill, Bash(npm *, npx *, node *, git *, make *, acli *), TaskCreate, TaskUpdate, TaskList
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`

## Process

### 1. Pre-flight

**Gate 1 — Plan required:**
Check if `.planning/STATE.md` exists.
- If not found → Stop. Tell the user: "An approved plan is required before implementation. Run `/plan` first to create `.planning/STATE.md`, then `/jira` to create tickets."
- If found → load it.

**Gate 2 — Jira ticket ID in STATE.md:**
Extract the Jira ticket ID from `.planning/STATE.md` (check the `**Source**` field and the `### Tickets` section).
- If no ticket ID is found in the file → Stop. Tell the user: "No Jira ticket ID found in `.planning/STATE.md`. Run `/jira` to create a ticket and record it in the plan, then re-run `/feature`."

**Gate 3 — Branch check:**
If on `main` or `master`, offer to create a feature branch per git conventions using the ticket ID from STATE.md.

**Fetch & confirm requirements:**
- Fetch ticket details: `acli jira workitem view <TICKET_ID>` — read scope, requirements, and acceptance criteria.
- Cross-reference the plan's Definition of Done and phases with the ticket's acceptance criteria. Note any mismatches and surface them to the user.
- Confirm scope with the user before continuing.

### 2. Design & Present

- Break down each plan phase into incremental milestones using `@references/templates.md`.

### 3. Implement

- Create a task per milestone with `TaskCreate`
- Set task dependencies using `addBlockedBy` where phases depend on prior phases

For each milestone:
- **Independent milestones** — dispatch an `implementation-worker` agent with explicit file scope, goal, and acceptance criteria.
  - Worker brief must include a **no drive-by edits** constraint: do not refactor, reformat, or clean up adjacent code; remove orphaned imports/vars caused by the change, but leave pre-existing dead code alone.
- **Sequential milestones** — implement inline, in order.

### 4. Verify, review, hand off

Run `/verify` → `/review`, then tell the user:

> "Implementation complete. Review the working-tree diff, then run `/commit` to commit and `/pr` to open the pull request when ready."

