#!/bin/bash
# Auto-format files after Write/Edit if prettier is available
# Event: PostToolUse
# Matcher: Write|Edit

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if command -v prettier &>/dev/null && echo "$FILE_PATH" | grep -qE '\.(ts|tsx|js|jsx|json|md)$'; then
  prettier --write "$FILE_PATH" 2>/dev/null || true
fi
exit 0
