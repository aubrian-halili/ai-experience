# Hook Patterns Catalog

## Prevention Patterns

### Block Force Push

Prevents `git push --force` and `git push -f`:

```bash
#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -qE 'git\s+push\s+.*(--force|-f)'; then
  echo "BLOCKED: Force push is not allowed. Use --force-with-lease instead." >&2
  exit 2
fi
exit 0
```

**Event:** `PreToolUse` | **Matcher:** `Bash`

### Block Sensitive File Edits

Prevents editing `.env`, secrets, or key files:

```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

SENSITIVE_PATTERNS=('\.env' '\.pem$' '\.key$' 'secrets' 'credentials')
for pattern in "${SENSITIVE_PATTERNS[@]}"; do
  if echo "$FILE_PATH" | grep -qiE "$pattern"; then
    echo "BLOCKED: Cannot edit sensitive file: $FILE_PATH" >&2
    exit 2
  fi
done
exit 0
```

**Event:** `PreToolUse` | **Matcher:** `Edit,Write`

### Enforce Lint Before Commit

Runs linter before allowing commit operations:

```bash
#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -qE 'git\s+commit'; then
  if ! npx eslint . --quiet 2>/dev/null; then
    echo "BLOCKED: Lint errors found. Fix them before committing." >&2
    exit 2
  fi
fi
exit 0
```

**Event:** `PreToolUse` | **Matcher:** `Bash`

## Logging Patterns

### Log All File Modifications

Tracks which files Claude modifies during a session:

```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "$TIMESTAMP | $TOOL_NAME | $FILE_PATH" >> .claude/hooks/modification-log.txt
exit 0
```

**Event:** `PostToolUse` | **Matcher:** `Edit,Write`

## Notification Patterns

### Notify on Completion

Sends a system notification when Claude finishes a task:

```bash
#!/bin/bash
if command -v osascript &>/dev/null; then
  osascript -e 'display notification "Claude has finished the task" with title "Claude Code"'
elif command -v notify-send &>/dev/null; then
  notify-send "Claude Code" "Claude has finished the task"
fi
exit 0
```

**Event:** `Stop`

## Configuration Examples

### Project-level settings.json

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/block-force-push.sh"
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/block-sensitive-files.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/log-modifications.sh"
          }
        ]
      }
    ]
  }
}
```

## Testing Hooks

Test a hook by piping sample JSON input:

```bash
# Test a PreToolUse hook
echo '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' | .claude/hooks/block-force-push.sh
echo "Exit code: $?"

# Test an Edit hook
echo '{"tool_name":"Edit","tool_input":{"file_path":"src/.env.local"}}' | .claude/hooks/block-sensitive-files.sh
echo "Exit code: $?"
```

Expected: exit code 2 (blocked) with message on stderr.
