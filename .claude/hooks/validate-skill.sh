#!/bin/bash
# Auto-validate skill files after Write/Edit operations on .claude/skills/
# Event: PostToolUse
# Matcher: Write|Edit

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Check if the changed file is a skill file
if ! echo "$FILE_PATH" | grep -qE '\.claude/skills/.*/SKILL\.md$'; then
  exit 0
fi

# Extract the skill directory
SKILL_DIR=$(dirname "$FILE_PATH")

# Run the validation script if it exists
VALIDATOR=".claude/skills/skill-creator/scripts/validate-skill.sh"
if [ -f "$VALIDATOR" ]; then
  OUTPUT=$(bash "$VALIDATOR" "$SKILL_DIR" 2>&1)
  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    echo "WARNING: Skill validation found issues in $(basename "$SKILL_DIR"):" >&2
    echo "$OUTPUT" >&2
    # Don't block — just warn. Exit 0 so the edit still applies.
  fi
fi

exit 0
