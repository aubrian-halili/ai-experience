---
name: subagent-driven-development
description: >-
  TRIGGER when: user asks to "run tasks in parallel", "speed this up with multiple agents", "parallelize
  this refactor", "use subagents", "fan out this work", or has a large implementation (3+ independent
  modules) that could be done concurrently. Use after /plan when the plan reveals independent work streams.
  DO NOT TRIGGER when: tasks have sequential dependencies (use /feature) or scope is a single file/module.
argument-hint: "[plan file, task list, or multi-module feature description]"
agent: implementation-worker
allowed-tools: Agent, Read, Grep, Glob, TaskCreate, TaskUpdate, TaskList
---

Orchestrate parallel implementation across multiple Claude subagents for large-scale features or refactors with clearly independent work streams.

## Orchestration Philosophy

- **Independence test first** — never parallelize tasks that share mutable state or have implicit ordering
- **Fresh agent per task** — each subagent starts clean to avoid context pollution and cross-task confusion
- **Two-stage review** — every subagent result is reviewed for spec compliance first, then code quality
- **Sequential fallback** — if tasks have dependencies, fall back to sequential `/feature` milestones
- **Tracked progress** — every dispatched task is tracked via TaskCreate/TaskUpdate for visibility

## Iron Laws

> - NEVER dispatch parallel tasks without verifying independence first
> - NEVER let a subagent modify files another subagent is also modifying
> - If any subagent fails, halt remaining dispatches and assess before continuing

## When to Use

### This Skill Is For

- Large refactors touching many independent modules
- Multi-feature plans where tasks share no files
- Parallel test generation across isolated components
- Batch operations across independent packages in a monorepo

### Use a Different Approach When

- Tasks have sequential dependencies → use `/feature` with milestones
- Work is in a single file or module → use `/feature` directly
- Need to plan before parallelizing → use `/plan` first
- Fewer than 3 independent tasks → overhead isn't worth it, use `/feature`

## Input Classification

| Input | Intent | Approach |
|-------|--------|----------|
| Plan file (e.g., `.planning/STATE.md`) | Parallelize plan phases | Extract independent phases, dispatch |
| Task list (inline or file) | Parallelize tasks | Validate independence, dispatch |
| Feature description | Decompose and parallelize | Decompose → independence test → dispatch |
| (none) | Ask user | Pre-flight stop |

## Process

### 1. Pre-flight

- Parse `$ARGUMENTS` and identify the work to parallelize
- If a plan exists, read `.planning/STATE.md` for phase breakdown
- Search the codebase to understand module boundaries and file ownership
- Use `TaskList` to check for existing tracked tasks

**Stop conditions:**
- No `$ARGUMENTS` provided → ask user what to parallelize
- Fewer than 3 tasks → recommend `/feature` instead (overhead not justified)
- No clear plan exists → recommend `/plan` first

### 2. Decompose

- Break work into discrete tasks, each with:
  - **Goal**: one-sentence description of the task outcome
  - **Files to modify/create**: explicit list
  - **Acceptance criteria**: how to verify the task is complete
  - **Dependencies**: what must be done before this task

- If decomposition comes from a plan, map plan phases to tasks

### 3. Independence Test

For each pair of tasks, verify:

- **No shared files**: tasks do not modify the same files
- **No shared state**: tasks do not depend on runtime state from other tasks
- **No ordering requirement**: task A's output is not task B's input
- **No shared interfaces**: if tasks modify interfaces, they modify different ones

**Decision matrix:**

| Independence Level | Action |
|--------------------|--------|
| Fully independent | Dispatch in parallel |
| Shared read-only dependencies | Dispatch in parallel (read-only is safe) |
| Shared mutable files | Cannot parallelize — use sequential `/feature` |
| Output-input chain | Cannot parallelize — use sequential `/feature` |

Present the independence analysis to the user before dispatching.

### 4. Dispatch

For each independent task:

1. Create a tracked task via `TaskCreate` with goal, files, and acceptance criteria
2. Mark as `in_progress` via `TaskUpdate`
3. Launch a fresh `implementation-worker` agent (from `.claude/agents/implementation-worker.md`) via the Agent tool with:
   - Task goal, file scope, and acceptance criteria as context in the prompt
   - Set `isolation: "worktree"` for each worker to prevent file conflicts between parallel agents
   - The agent has Edit, Write, and scoped Bash access (test commands only)
4. Dispatch independent tasks in parallel (multiple Agent calls in one message)

**Dispatch format** — pass the task contract to each `implementation-worker`:
```
Task: [goal]
Files to modify: [list]
Files to create: [list, if any]
Acceptance criteria: [list]
Context: [relevant background, patterns to follow, conventions]
```

> Note: Each `implementation-worker` runs in an isolated git worktree. The orchestrator (this skill) is responsible for merging results and resolving any integration issues after all workers complete.

### 5. Review Results

For each completed subagent:

**Stage 1 — Spec Compliance:**
- Does the result satisfy the acceptance criteria?
- Were only the specified files modified?
- Are there any unintended side effects?

**Stage 2 — Code Quality:**
- Does the code follow existing codebase patterns?
- Are there anti-patterns (stubs, TODOs, empty catches)?
- Do new tests pass?

Mark tasks as `completed` via `TaskUpdate` only after both stages pass.

### 6. Integrate

- Verify no merge conflicts between parallel changes
- Run the full test suite to check for integration issues
- If conflicts exist, resolve them manually (subagents cannot see each other's changes)
- Use `TaskList` to confirm all tasks are completed
- Recommend `/verify` for comprehensive post-integration verification

## Output Principles

- **Independence proof** — always show the independence analysis before dispatching
- **Tracked progress** — every task visible via TaskList at all times
- **Two-stage quality** — spec compliance before code quality, always
- **Integration verification** — parallel results must be verified together, not just individually

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Ask user what to parallelize |
| Plan file | Extract independent phases, run full workflow |
| Task list | Validate independence, dispatch |
| Feature description | Decompose first, then parallelize what's independent |

## Error Handling

| Scenario | Response |
|----------|----------|
| Tasks not independent | Fall back to sequential `/feature` milestones |
| Subagent fails | Mark task as blocked, assess whether to retry or restructure |
| Merge conflicts | Resolve manually, re-run integration tests |
| Fewer than 3 tasks | Recommend `/feature` instead |
| One subagent modifies unexpected files | Revert its changes, re-dispatch with stricter scope |
| Integration tests fail | Identify which parallel change caused the failure, fix in isolation |

Never dispatch tasks without proving independence first — the cost of parallel conflicts exceeds the time saved.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/plan` | Need to decompose work before parallelizing |
| `/feature` | Tasks have dependencies, use sequential milestones |
| `/verify` | Post-integration verification of parallel results |
| `/review` | Code quality review of individual subagent outputs |
| `/explore` | Understand codebase before defining task boundaries |
| `/architecture` | Ensure clear architectural boundaries for parallel work |
