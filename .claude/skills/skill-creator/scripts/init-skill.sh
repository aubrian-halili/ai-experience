#!/bin/bash
# Initialize a new Claude Code skill with boilerplate structure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
TEMPLATE_PATH="$(dirname "$SCRIPT_DIR")/template.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <skill-name>"
    echo ""
    echo "Creates a new skill directory with boilerplate SKILL.md"
    echo ""
    echo "Arguments:"
    echo "  skill-name    Name of the skill (kebab-case, e.g., 'my-skill')"
    echo ""
    echo "Example:"
    echo "  $0 code-review"
    exit 1
}

# Check for skill name argument
if [ -z "$1" ]; then
    echo -e "${RED}Error: No skill name provided${NC}"
    echo ""
    usage
fi

SKILL_NAME="$1"

# Validate kebab-case naming
if ! echo "$SKILL_NAME" | grep -qE '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'; then
    echo -e "${RED}Error: Skill name must be kebab-case${NC}"
    echo "  Valid:   my-skill, code-review, api-client"
    echo "  Invalid: MySkill, code_review, API-client"
    exit 1
fi

SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"

# Check if skill already exists
if [ -d "$SKILL_DIR" ]; then
    echo -e "${YELLOW}Warning: Skill '$SKILL_NAME' already exists at $SKILL_DIR${NC}"
    read -p "Overwrite? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Aborted."
        exit 0
    fi
fi

# Create skill directory
mkdir -p "$SKILL_DIR"

# Copy template and replace placeholder
if [ -f "$TEMPLATE_PATH" ]; then
    sed "s/\[skill-name\]/$SKILL_NAME/g" "$TEMPLATE_PATH" > "$SKILL_DIR/SKILL.md"
else
    echo -e "${RED}Error: Template not found at $TEMPLATE_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Created skill: $SKILL_NAME${NC}"
echo ""
echo "Directory: $SKILL_DIR"
echo ""
echo "Next steps:"
echo "  1. Edit $SKILL_DIR/SKILL.md"
echo "     - Update the description with trigger phrases"
echo "     - Define when to use this skill"
echo "     - Write the process steps"
echo "     - Specify the response format"
echo ""
echo "  2. Validate the skill:"
echo "     $SCRIPT_DIR/validate-skill.sh $SKILL_NAME"
echo ""
echo "  3. Test by invoking /$SKILL_NAME"
