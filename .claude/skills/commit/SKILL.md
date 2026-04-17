---
name: commit
description: User asks to "commit", "create a commit", "commit my changes", or mentions "git commit".
argument-hint: "[optional commit message or scope]"
allowed-tools: Bash(git *), Read, Grep, Glob
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`
**Recent commits:**
!`git log --oneline -3`
