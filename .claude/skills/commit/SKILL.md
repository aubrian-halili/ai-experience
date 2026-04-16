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

Generate semantic commit messages following project conventions (see CLAUDE.md).

## Commit Philosophy

- **Atomic commits** — each commit should represent one logical change; split multi-concern changes into separate commits

## Input Handling

Determine commit workflow from `$ARGUMENTS`:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Full commit workflow | Steps 1-3; analyze all changes |
| Commit message text | Use as proposed message | Steps 1-3; skip message generation |
| Scope hint (e.g., `auth`) | Scope-focused commit | Steps 1-3; filter analysis to scope |
| `--amend` | Amend last commit | Steps 1-3; warn if already pushed |

## Process

### 1. Pre-flight Checks

Extract ticket ID from the branch name shown above (e.g., `UN-4032` from `UN-4032-skill-optimization`).

**Stop conditions:** Follow branch/ticket rules from git-conventions.md — no changes → nothing to commit.

### 2. Analyze & Present for Review

Use `$ARGUMENTS` if provided (user's custom message or scope), otherwise generate an appropriate commit message.

**Present to user:**
- Show **staged files** separately from **unstaged files**
- Show the proposed commit message (with body if needed)
- Ask the user to review and confirm before proceeding

### 3. Stage & Commit

Stage and commit the approved changes.

## Output Principles

- **Staged vs unstaged clarity** — always show staged and unstaged files separately so the user knows exactly what will be committed
- **Message preview** — show the complete commit message (subject + body) formatted exactly as it will appear in git log

## Error Handling

| Scenario | Response |
|----------|----------|
| Mixed change types | Recommend splitting into multiple commits |
| Unclear scope | Ask for clarification or suggest based on files |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Review changes before committing |
| `/pr` | Create pull request after committing |
| `/review --refactor` | Clean up code before committing |
| `/jira` | Look up or update Jira ticket details |
| `/finish` | Wrap up branch after all changes are committed |
