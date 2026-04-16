---
name: commit
description: >-
  User asks to "commit", "create a commit", "commit my changes", or mentions "git commit".
  Not for: creating a PR (use /pr) or pushing changes (use /pr).
argument-hint: "[optional commit message or scope]"
allowed-tools: Bash(git *), Read, Grep, Glob
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`
**Recent commits:**
!`git log --oneline -3`

## Input Handling

Determine commit workflow from `$ARGUMENTS`:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Full commit workflow | Steps 1-2; analyze all changes |
| Commit message text | Use as proposed message | Steps 1-2; skip message generation |
| Scope hint (e.g., `auth`) | Scope-focused commit | Steps 1-2; filter analysis to scope |
| `--amend` | Amend last commit | Steps 1-2; warn if already pushed |

## Process

### 1. Analyze & Present for Review

Use `$ARGUMENTS` if provided (user's custom message or scope), otherwise generate an appropriate commit message.

**Present to user:**
- Show the proposed commit message (with body if needed)
- Ask the user to review and confirm before proceeding
