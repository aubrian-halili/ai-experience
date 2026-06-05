#!/bin/bash
# Enforce Jira ticket ID prefix in branch names when creating new branches
# Event: PreToolUse
# Matcher: Bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Split compound commands on &&, ;, | so commit messages or other args
# don't accidentally match the branch-creation patterns below.
while IFS= read -r segment; do
  segment=$(echo "$segment" | sed 's/^[[:space:]]*//')

  # Only check segments that are branch creation commands
  if ! echo "$segment" | grep -qE '^git (checkout -b|branch|switch -c)'; then
    continue
  fi

  # Extract the branch name from the segment
  BRANCH_NAME=""

  if echo "$segment" | grep -qE '^git checkout -b'; then
    BRANCH_NAME=$(echo "$segment" | grep -oE 'checkout -b\s+\S+' | awk '{print $NF}')
  elif echo "$segment" | grep -qE '^git switch -c'; then
    BRANCH_NAME=$(echo "$segment" | grep -oE 'switch -c\s+\S+' | awk '{print $NF}')
  elif echo "$segment" | grep -qE '^git branch\s+[^-]'; then
    BRANCH_NAME=$(echo "$segment" | grep -oE 'git branch\s+\S+' | awk '{print $NF}')
  fi

  # Skip if we couldn't extract a branch name (e.g., git branch -d, git branch --list)
  if [ -z "$BRANCH_NAME" ]; then
    continue
  fi

  # Skip special branch names
  if echo "$BRANCH_NAME" | grep -qE '^(main|master|develop|staging|release)'; then
    continue
  fi

  # Check for Jira ticket ID prefix (e.g., UN-1234)
  if ! echo "$BRANCH_NAME" | grep -qE '^[A-Z]+-[0-9]+'; then
    echo "BLOCKED: Branch name must start with a Jira ticket ID (e.g., UN-1234-feature-name)" >&2
    exit 2
  fi
done < <(echo "$COMMAND" | sed 's/&&/\n/g; s/;/\n/g; s/|/\n/g')

exit 0
