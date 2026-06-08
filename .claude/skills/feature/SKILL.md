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

A feature is **only 100% complete** when all four Definition-of-Done gates pass. Do not declare completion until every box is ticked.

**Definition of Done**

- [ ] **DoD-1 — STATE.md exists:** `.planning/STATE.md` is present (already enforced by Gate 1).
- [ ] **DoD-2 — Jira ticket recorded:** ticket ID is present in `.planning/STATE.md` (already enforced by Gate 2).
- [ ] **DoD-3 — `/verify` passes:** run `/verify` against the plan's Definition of Done. Required outcome: **PASS**. `PARTIAL`, `FAIL`, or `SKIP` blocks completion — address findings and re-run.
- [ ] **DoD-4 — `/review` passes:** run `/review` on the local changes. Required outcome: no blocking findings (High-severity or correctness issues). Address blocking findings and re-run; non-blocking findings should be surfaced to the user but do not block hand-off.

**Hand-off message (only after all four gates pass):**

> "Implementation complete — DoD-1 (STATE.md) ✓, DoD-2 (Jira ticket <ID>) ✓, DoD-3 (/verify PASS) ✓, DoD-4 (/review clean) ✓. Review the working-tree diff, then run `/commit` to commit and `/pr` to open the pull request when ready."

**If any gate fails:** report which gate(s) failed with `file:line` evidence and stop. Do not say "implementation complete."

