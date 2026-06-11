---
name: feature
description: >-
  Implement an approved plan (e.g., "implement the plan", "build the feature", "start working on it")
  through test-driven milestones, then gate completion on /verify PASS and /review clean before handing off to the user for /commit and /pr.
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
- If not found → stop and instruct the user to run `/plan` then `/jira` before re-running.
- If found → load it.

**Gate 2 — Jira ticket ID in STATE.md:**
Extract the Jira ticket ID from `.planning/STATE.md`.
- If no ticket ID is found → stop and instruct the user to run `/jira` to record one, then re-run.

**Gate 3 — Branch check:**
If on `main` or `master`, offer to create a feature branch per git conventions using the ticket ID from STATE.md.

**Fetch requirements:**
- Fetch ticket details: `acli jira workitem view <TICKET_ID>` — read scope, requirements, and acceptance criteria.
- Cross-reference the plan's Definition of Done and phases with the ticket's acceptance criteria. If scope diverges, pause for user resolution.

### 2. Design

- Break down each plan phase into incremental milestones using `@references/templates.md`.

### 3. Implement

- Create a task per milestone with `TaskCreate`
- Set task dependencies using `addBlockedBy` where phases depend on prior phases

For each milestone:
- **Independent milestones** — dispatch an `implementation-worker` agent with explicit file scope, goal, and acceptance criteria.
  - Worker brief must specify: remove orphaned imports/vars caused by the change, but leave pre-existing dead code alone.
- **Sequential milestones** — implement inline, in order.

### 4. Verify, review, hand off

Invoke `/gate` (feature mode — no PR argument). It runs completeness verification against `.planning/STATE.md` and the code review **in parallel** and emits one verdict. A feature is complete only when `/gate` returns **READY** (VERIFY **PASS** and no Blocking/correctness findings).

If `/gate` returns **BLOCKED**, report the blockers with `file:line` evidence and stop.
On success, tell the user the gate passed and to run `/commit` then `/pr`.

