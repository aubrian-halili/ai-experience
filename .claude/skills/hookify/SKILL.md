---
name: hookify
description: >-
  User asks to "create a Claude Code hook", "add a guardrail", "block certain commands",
  or mentions "PreToolUse", "PostToolUse". This is for Claude Code hooks, not React
  hooks or git hooks.
  Not for: git hooks (handle those manually).
  Not for: creating skills or slash commands (use /skill-creator).
argument-hint: "[hook type or behavior to enforce]"
allowed-tools: Read, Write, Edit, Bash(chmod *), Glob
disable-model-invocation: true
---

Guide creation and management of Claude Code hooks for enforcing behaviors, protecting files, and automating workflows.

## Process

### 1. Pre-flight

- Check for existing hooks in `.claude/settings.json` and `.claude/settings.local.json`
- Identify the target settings file (project-level vs user-level)

**Stop condition:** No `$ARGUMENTS` and no clear hook intent → show available hook events and ask what behavior to enforce

### 2. Present Plan

Before writing any files, present:

- **Event**: which hook event will be used
- **Matcher**: which tool or condition triggers it
- **Script logic**: what the hook will do (block, log, notify) and the exit code behavior
- **Target settings file**: project-level (`.claude/settings.json`) or user-level (`.claude/settings.local.json`)

### 3. Implement Hook

Create hook script and register in settings. See `@references/hook-patterns.md` for ready-to-use implementations.
