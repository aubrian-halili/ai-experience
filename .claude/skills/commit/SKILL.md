---
name: commit
description: >-
  User asks to "commit", "create a commit", "commit my changes", "stage and commit", or mentions "git commit".
  Enforces the project convention "<JIRA-ID> <type>(<scope>): <description>" (Jira ID extracted from the current branch)
  and always presents the proposed message for confirmation before committing.
  Not for: creating a pull request (use /pr).
argument-hint: "[optional commit message or scope]"
allowed-tools: Bash(git *), Read, Grep, Glob
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`
**Recent commits:**
!`git log --oneline -3`

## Project rule

Commit messages must follow `<JIRA-ID> <type>(<scope>): <description>` — extract the Jira ID from the current branch name. See `.claude/rules/git-conventions.md`.

## Process

### 1. Analyze & Present for Review

Present the proposed commit message to the user for review and confirmation before proceeding.
