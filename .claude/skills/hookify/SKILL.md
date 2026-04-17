---
name: hookify
description: >-
  User asks to "create a Claude Code hook", "add a guardrail", "block certain commands",
  or mentions "PreToolUse", "PostToolUse". This is for Claude Code hooks, not React
  hooks or git hooks.
  Not for: git hooks (handle those manually).
argument-hint: "[hook type or behavior to enforce]"
allowed-tools: Read, Write, Edit, Bash(chmod *), Glob
disable-model-invocation: true
---

## Process

### 1. Present Plan

- **Event**: which hook event will be used
- **Matcher**: which tool or condition triggers it
- **Script logic**: what the hook will do (block, log, notify) and the exit code behavior
- **Target settings file**: project-level (`.claude/settings.json`) or user-level (`.claude/settings.local.json`)

### 2. Implement Hook

Create hook script and register in settings. See `@references/hook-patterns.md` for ready-to-use implementations.
