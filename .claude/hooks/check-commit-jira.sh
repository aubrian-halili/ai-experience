#!/bin/bash
# Check if git commit has Jira ticket ID prefix

if echo "$TOOL_INPUT" | grep -q 'git commit' && ! echo "$TOOL_INPUT" | grep -qE '[A-Z]+-[0-9]+'; then
  echo "BLOCKED: Commit message must start with JIRA ticket ID (e.g., UN-1234)" >&2
  exit 2
fi
exit 0
