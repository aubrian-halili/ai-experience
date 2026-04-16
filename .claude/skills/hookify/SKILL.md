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

## Hook Philosophy

- **Prevention over detection** — hooks that block unwanted actions before they happen are more valuable than ones that report after the fact
- **Fail-safe defaults** — if a hook errors, it should block the action (fail closed) rather than silently allow it

## Input Handling

Classify `$ARGUMENTS` to determine the hook workflow:

| Input | Intent | Approach |
|-------|--------|----------|
| Hook type (e.g., `PreToolUse`) | Create hook for event | Scaffold hook for that event type |
| Behavior description (e.g., `prevent force push`) | Enforce behavior | Match to pattern, create appropriate hook |
| `list` or `validate` | Manage existing hooks | Inventory and test current hooks |

## Process

### 1. Pre-flight

- Classify hook intent from `$ARGUMENTS` using the Input Handling table
- Check for existing hooks in `.claude/settings.json` and `.claude/settings.local.json`
- Identify the target settings file (project-level vs user-level)

**Stop conditions:**
- No `$ARGUMENTS` and no clear hook intent → show available hook events and ask what behavior to enforce
- Request is for git hooks, not Claude Code hooks → clarify the distinction and redirect

### 2. Design Hook

Determine the hook event, matcher, script logic, and target settings file (project-level vs user-level).

### 2.5. Present Plan for Approval

**Before writing any files**, present the planned hook to the user and wait for explicit approval:

- **Event**: which hook event will be used
- **Matcher**: which tool or condition triggers it
- **Script logic**: what the hook will do (block, log, notify) and the exit code behavior
- **Target settings file**: project-level (`.claude/settings.json`) or user-level (`.claude/settings.local.json`)

**Do not proceed to Step 3 until the user confirms the plan.**

### 3. Implement Hook

Create hook script and register in settings. See `@references/hook-patterns.md` for ready-to-use implementations.

### 4. Validate

Test the hook works correctly:

1. Test with sample input matching the expected JSON format
2. Verify it blocks when it should (exit 2) and allows when it should (exit 0)
3. Check that stderr messages are informative when blocking

## Common Hook Patterns

See `@references/hook-patterns.md` for detailed pattern implementations.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/skill-creator` | Creating skills, not hooks |
| `/review` | Review hook script quality and logic |
