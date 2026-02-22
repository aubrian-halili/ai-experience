#!/bin/bash
# Auto-format files after Write/Edit if prettier is available

if command -v prettier &>/dev/null && echo "$FILE_PATH" | grep -qE '\.(ts|tsx|js|jsx|json|md)$'; then
  prettier --write "$FILE_PATH" 2>/dev/null || true
fi
exit 0
