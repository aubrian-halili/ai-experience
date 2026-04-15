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

Based on the desired behavior:

1. **Select event**: Match behavior to the appropriate hook event
2. **Define matcher**: Determine which tool calls or conditions trigger the hook
3. **Plan action**: What the hook script should do (block, modify, log, notify)
4. **Choose scope**: Project-level (`.claude/settings.json`) or user-level (`.claude/settings.local.json`)

**Hook Events Reference:**

| Event | Timing | Use Cases |
|-------|--------|-----------|
| **Tool lifecycle** | | |
| `PreToolUse` | Before a tool executes | Block dangerous commands, validate inputs, auto-approve safe ops |
| `PostToolUse` | After a tool executes | Log actions, trigger follow-ups, auto-format |
| **Session lifecycle** | | |
| `SessionStart` | Session begins | Set up env, check prerequisites, load context |
| `SessionEnd` | Session ends | Cleanup, save summaries |
| `Stop` | Claude stops responding | Cleanup, summary generation, notifications |
| `StopFailure` | Claude fails to stop cleanly | Error recovery, alerting |
| `SubagentStart` | Subagent spawns | Logging, pre-checks |
| `SubagentStop` | Subagent finishes | Aggregate results, quality checks |
| **User interaction** | | |
| `UserPromptSubmit` | User sends a message | Input validation, preprocessing |
| `Notification` | On notifications | Custom alerts, integrations |
| **Context management** | | |
| `PreCompact` | Before context compaction | Save important state |
| `PostCompact` | After context compaction | Re-inject critical context |

### 2.5. Present Plan for Approval

**Before writing any files**, present the planned hook to the user and wait for explicit approval:

- **Event**: which hook event will be used
- **Matcher**: which tool or condition triggers it
- **Script logic**: what the hook will do (block, log, notify) and the exit code behavior
- **Target settings file**: project-level (`.claude/settings.json`) or user-level (`.claude/settings.local.json`)

**Do not proceed to Step 3 until the user confirms the plan.**

### 3. Implement Hook

Create the hook script and configuration:

1. **Write the hook script** in `.claude/hooks/` directory
   - Use bash for simple hooks, or the appropriate language for complex logic; prefer bash + jq, avoid requiring additional tools
   - Include proper error handling and exit codes
   - Exit 0 to allow, exit 2 to block (with stderr message shown to user)
2. **Make executable**: `chmod +x $CLAUDE_PROJECT_DIR/.claude/hooks/<script-name>`
3. **Register in settings**: Add hook configuration to the appropriate settings file

**Hook Types:**

| Type | Key Fields | Use Case |
|------|-----------|----------|
| `command` | `command`, `timeout` | Run a shell script |
| `http` | `url`, `headers` | Call a webhook/API endpoint |
| `prompt` | `prompt`, `model` | LLM-based judgment — no script needed |
| `agent` | `prompt`, `model` | Multi-step LLM reasoning with tool access |

Common optional fields (all types): `timeout` (seconds), `async` (bool, fire-and-forget), `statusMessage` (shown in UI while hook runs).

**Hook Configuration Schema:**

```json
{
  "hooks": {
    "<event>": [
      {
        "matcher": "<tool-name-pattern>",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/<script-name>"
          }
        ]
      }
    ]
  }
}
```

For LLM-based decisions without a shell script, use a `prompt` hook:

```json
{
  "type": "prompt",
  "prompt": "Check if the file being edited contains secrets or credentials. If so, respond with permissionDecision: deny and explain why.",
  "model": "claude-haiku-4-5-20251001"
}
```

**Hook Script Template:**

```bash
#!/bin/bash
# Hook: <description>
# Event: <event-type>
# Matcher: <pattern>

# Read input from stdin (JSON with tool name, input, etc.)
INPUT=$(cat)

# Extract relevant fields
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty')

# Your logic here
# Exit 0 = allow, Exit 2 = block (stderr shown to user)

exit 0
```

**Structured Output (JSON on stdout):**

For richer control than exit codes alone, hooks can write JSON to stdout:

```bash
# PreToolUse — control the permission decision
echo '{"hookSpecificOutput":{"permissionDecision":"allow"}}'   # auto-approve, skip prompt
echo '{"hookSpecificOutput":{"permissionDecision":"deny"}}'    # block (equivalent to exit 2)
echo '{"hookSpecificOutput":{"permissionDecision":"ask"}}'     # defer to normal permission flow

# PostToolUse / Stop — block the action
echo '{"decision":"block","reason":"Reason shown to user"}'

# Any event — inject context or modify output
echo '{"additionalContext":"Text injected into Claude'\''s next turn"}'
echo '{"suppressOutput":true}'                                 # hide hook output from user
echo '{"systemMessage":"Warning shown to Claude"}'
```

Exit codes still apply: `0` = allow (parse stdout for JSON decisions), `2` = block (write reason to stderr).

### 4. Validate

Test the hook works correctly:

1. Test with sample input matching the expected JSON format
2. Verify it blocks when it should (exit 2) and allows when it should (exit 0)
3. Check that stderr messages are informative when blocking

## Common Hook Patterns

See `@references/hook-patterns.md` for detailed pattern implementations.

## Error Handling

| Scenario | Response |
|----------|----------|
| No `.claude/settings.json` found | Create it with the hook configuration |
| Hook script has syntax errors | Test with `bash -n` before registering |
| jq not available | Suggest installation or provide jq-free alternative using grep/sed |
| Stop hook causes infinite loop | Check `stop_hook_active` field in stdin JSON; skip logic if `true` |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/skill-creator` | Creating skills, not hooks |
| `/review` | Review hook script quality and logic |
