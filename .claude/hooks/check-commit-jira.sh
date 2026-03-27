#!/bin/bash
# Check if git commit has Jira ticket ID prefix
# Event: PreToolUse
# Matcher: Bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -q 'git commit' && ! echo "$COMMAND" | grep -qE '[A-Z]+-[0-9]+'; then
  echo "BLOCKED: Commit message must start with JIRA ticket ID (e.g., UN-1234)" >&2
  exit 2
fi
exit 0
