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

## Project rule

Commit messages must follow `<JIRA-ID> <type>(<scope>): <description>` — extract the Jira ID from the current branch name. See `.claude/rules/git-conventions.md`.
