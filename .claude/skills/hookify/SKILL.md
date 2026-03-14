---
name: hookify
description: >-
  User asks to "create a Claude Code hook", "add a guardrail", "block certain commands",
  or mentions "PreToolUse", "PostToolUse". This is for Claude Code hooks, not React
  hooks or git hooks.
  Not for: React hooks (use /react).
argument-hint: "[hook type or behavior to enforce]"
allowed-tools: Read, Write, Edit, Bash(chmod *), Glob
disable-model-invocation: true
---

Guide creation and management of Claude Code hooks for enforcing behaviors, protecting files, and automating workflows.

## Hook Philosophy

- **Prevention over detection** — hooks that block unwanted actions before they happen are more valuable than ones that report after the fact
- **Minimal friction** — hooks should be fast and silent when conditions are met; only surface when they block something
- **Fail-safe defaults** — if a hook errors, it should block the action (fail closed) rather than silently allow it
- **Composable** — each hook does one thing well; combine multiple hooks for layered enforcement

## Input Handling

Classify `$ARGUMENTS` to determine the hook workflow:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Explore hook options | Show available hook events and common patterns |
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
| `PreToolUse` | Before a tool executes | Block dangerous commands, validate inputs |
| `PostToolUse` | After a tool executes | Log actions, trigger follow-ups |
| `Notification` | On notifications | Custom alerts, integrations |
| `Stop` | When Claude stops | Cleanup, summary generation |
| `SubagentStop` | When a subagent finishes | Aggregate results, quality checks |

### 3. Implement Hook

Create the hook script and configuration:

1. **Write the hook script** in `.claude/hooks/` directory
   - Use bash for simple hooks, or the appropriate language for complex logic
   - Include proper error handling and exit codes
   - Exit 0 to allow, exit 2 to block (with stderr message shown to user)
2. **Make executable**: `chmod +x .claude/hooks/<script-name>`
3. **Register in settings**: Add hook configuration to the appropriate settings file

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
            "command": ".claude/hooks/<script-name>"
          }
        ]
      }
    ]
  }
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

### 4. Validate

Test the hook works correctly:

1. Verify the script is executable
2. Test with sample input matching the expected JSON format
3. Verify it blocks when it should (exit 2) and allows when it should (exit 0)
4. Check that stderr messages are informative when blocking

### 5. Document

Add a brief comment in the hook script explaining:
- What behavior it enforces
- What event and matcher it responds to
- How to disable it if needed

## Common Hook Patterns

See `@references/hook-patterns.md` for detailed pattern implementations.

## Output Principles

- **Working code first** — provide a complete, tested hook script, not pseudocode
- **Security-conscious** — hooks that protect sensitive operations should fail closed
- **Well-documented** — each hook includes inline comments explaining the logic
- **Minimal dependencies** — prefer bash + jq; avoid requiring additional tools

## Error Handling

| Scenario | Response |
|----------|----------|
| No `.claude/settings.json` found | Create it with the hook configuration |
| Hook script not executable | Fix permissions with `chmod +x` |
| Invalid JSON in settings file | Report the parse error location and fix |
| Hook script has syntax errors | Test with `bash -n` before registering |
| jq not available | Suggest installation or provide jq-free alternative using grep/sed |
| Hook blocks unintentionally | Guide debugging with test input and stderr output |

Never create hooks that silently swallow errors — always surface blocking reasons to the user via stderr.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/skill-creator` | Creating skills, not hooks |
| `/security` | Security audit rather than enforcement hooks |
| `/claude-md-management` | Managing CLAUDE.md rather than hooks |
| `/explore` | Understanding existing hook implementations |
