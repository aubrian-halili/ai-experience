---
name: finish
description: >-
  User says "I'm done", "finish this branch", "wrap up", or has completed
  implementation and needs to decide next steps.
  Not for: committing (use /commit) or creating a PR (use /pr).
argument-hint: "[optional: merge, pr, park, discard]"
allowed-tools: Bash(git *, gh *), Read, Grep, Glob
---

**Current branch:** !`git branch --show-current`

Unified branch completion workflow — verify, decide, and clean up when implementation work is done.

## Philosophy

- **Verify before finishing** — never mark work as done without evidence
- **Four clear options** — merge, PR, park, or discard; no ambiguity about what happens to the branch
- **Clean up after yourself** — worktrees, stale branches, and dangling state get addressed, not ignored

## Iron Laws

> - NO completion without passing tests (if tests exist)
> - NO discard without explicit user confirmation
> - Always check for worktrees created by `/subagent-driven-development`

## Process

### 1. Pre-flight Verification

- Run the test suite (if one exists) and confirm all tests pass
  - If tests fail, STOP — report failures and recommend `/debug`
- Check for uncommitted changes — if found, ask whether to commit or stash
- Check for TODO/FIXME comments in files changed on this branch (`git diff main --name-only`)

**Stop conditions:**
- Tests fail → report and stop
- On main/master branch → warn user (nothing to finish)
- No commits ahead of base branch → nothing to finish

### 2. Determine Base Branch

- Detect the base branch from the branch's merge-base with `main` or `master`
- Show a summary: commits ahead, files changed, lines added/removed

### 3. Present Options

If `$ARGUMENTS` specifies an option, skip to execution. Otherwise present all four:

| Option | When to Use |
|--------|-------------|
| **1. Create PR** | Ready for review — delegates to `/pr` workflow |
| **2. Merge locally** | Small change, no review needed — fast-forward merge into base branch |
| **3. Park branch** | Work-in-progress — push branch to remote for safekeeping, switch to base |
| **4. Discard** | Abandoned work — delete branch and changes (requires confirmation) |

### 4. Execute

**Option 1 — Create PR:**
- Delegate to the `/pr` skill workflow
- After PR creation, offer to switch back to the base branch

**Option 2 — Merge locally:**
- `git checkout <base>` and `git merge --ff-only <branch>` (if fast-forward fails, recommend PR instead)
- Delete the feature branch after successful merge

**Option 3 — Park branch:**
- Commit any uncommitted changes with a `WIP:` prefix message
- `git push -u origin <branch>`
- Switch to the base branch
- Report the branch name for future `git checkout`

**Option 4 — Discard:**
- Show the full diff one more time
- Ask for explicit confirmation: "This will delete branch `<name>` and all uncommitted changes. Type the branch name to confirm."
- Only proceed if user types the branch name
- `git checkout <base>` then `git branch -D <branch>`

### 5. Clean Up

- Check for orphaned worktrees (`git worktree list`) and offer to prune them
- Report final state: current branch, any remaining stashed work

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Run full workflow with option selection |
| `pr` | Skip to Create PR (still runs pre-flight) |
| `merge` | Skip to Merge locally (still runs pre-flight) |
| `park` | Skip to Park branch (still runs pre-flight) |
| `discard` | Skip to Discard (still runs pre-flight + confirmation) |

## Error Handling

| Scenario | Response |
|----------|----------|
| Tests fail | Stop and report — do not offer completion options |
| Merge conflicts on local merge | Abort merge, recommend PR instead |
| No remote configured | Skip park/PR options, offer merge or discard only |
| Uncommitted changes | Ask whether to commit or stash before proceeding |
| Worktree in use | Warn user, do not prune active worktrees |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/commit` | Just want to commit, not finish the branch |
| `/pr` | Specifically want to create a PR with full description |
| `/verify` | Want to check completeness before finishing |
| `/subagent-driven-development` | Created worktrees that need integration before finishing |
