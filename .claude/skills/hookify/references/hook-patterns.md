# Hook Patterns Catalog

## Prevention Patterns

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

**Event:** `PreToolUse` | **Matcher:** `Edit|Write`

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

**Event:** `PostToolUse` | **Matcher:** `Edit|Write`

## Structured Output Patterns

### Auto-Approve Safe Read Operations

Demonstrates `permissionDecision: "allow"` to skip the permission prompt for known-safe operations:

```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Block reads of sensitive files
if echo "$FILE_PATH" | grep -qiE '\.env|\.pem$|\.key$|secrets|credentials'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"}}'
  exit 0
fi

# Auto-approve all other reads (skip permission prompt)
echo '{"hookSpecificOutput":{"permissionDecision":"allow"}}'
exit 0
```

**Event:** `PreToolUse` | **Matcher:** `Read`
