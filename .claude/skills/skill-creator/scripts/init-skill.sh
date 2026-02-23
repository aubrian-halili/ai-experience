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

WITH_REFERENCES=false
WITH_SCRIPTS=false
FORCE_OVERWRITE=false

usage() {
    echo "Usage: $0 [OPTIONS] <skill-name>"
    echo ""
    echo "Creates a new skill directory with boilerplate SKILL.md"
    echo ""
    echo "Options:"
    echo "  --with-references    Create references/ subdirectory"
    echo "  --with-scripts       Create scripts/ subdirectory"
    echo "  --force              Overwrite existing skill without prompt"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Arguments:"
    echo "  skill-name    Name of the skill (kebab-case, e.g., 'my-skill')"
    echo ""
    echo "Example:"
    echo "  $0 code-review"
    echo "  $0 --with-references api-client"
    echo "  $0 --with-references --with-scripts api-client"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --with-references)
            WITH_REFERENCES=true
            shift
            ;;
        --with-scripts)
            WITH_SCRIPTS=true
            shift
            ;;
        --force)
            FORCE_OVERWRITE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            SKILL_NAME="$1"
            shift
            ;;
    esac
done

# Check for skill name argument
if [ -z "$SKILL_NAME" ]; then
    echo -e "${RED}Error: No skill name provided${NC}"
    echo ""
    usage
fi

# Validate kebab-case naming
if ! echo "$SKILL_NAME" | grep -qE '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'; then
    echo -e "${RED}Error: Skill name must be kebab-case${NC}"
    echo "  Valid:   my-skill, code-review, api-client"
    echo "  Invalid: MySkill, code_review, API-client"
    exit 1
fi

# Validate name length (max 64 chars)
NAME_LENGTH=${#SKILL_NAME}
if [ $NAME_LENGTH -gt 64 ]; then
    echo -e "${RED}Error: Skill name must be 64 characters or less${NC}"
    echo "  Current length: $NAME_LENGTH"
    echo "  Shorten by: $((NAME_LENGTH - 64)) characters"
    exit 1
fi

# Check for reserved words
if echo "$SKILL_NAME" | grep -qiE 'anthropic|claude'; then
    echo -e "${RED}Error: Skill name cannot contain reserved words${NC}"
    echo "  Reserved words: 'anthropic', 'claude'"
    echo "  Your name: $SKILL_NAME"
    exit 1
fi

SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"

# Check if skill already exists
if [ -d "$SKILL_DIR" ]; then
    echo -e "${YELLOW}Warning: Skill '$SKILL_NAME' already exists at $SKILL_DIR${NC}"

    if [ "$FORCE_OVERWRITE" = false ]; then
        # Check if running in a terminal (interactive)
        if [ -t 0 ]; then
            read -p "Overwrite? (y/N): " confirm
            if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
                echo "Aborted."
                exit 0
            fi
        else
            # Not in a terminal, default to abort for safety
            echo "Not running in interactive terminal. Use --force to overwrite."
            echo "Aborted."
            exit 0
        fi
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

# Create references directory if requested
if [ "$WITH_REFERENCES" = true ]; then
    mkdir -p "$SKILL_DIR/references"
    echo -e "${GREEN}✓ Created references/ directory${NC}"
fi

# Create scripts directory if requested
if [ "$WITH_SCRIPTS" = true ]; then
    mkdir -p "$SKILL_DIR/scripts"
    echo -e "${GREEN}✓ Created scripts/ directory${NC}"
fi

echo -e "${GREEN}✓ Created skill: $SKILL_NAME${NC}"
echo ""
echo "Directory: $SKILL_DIR"
echo ""
STEP=1
echo "Next steps:"
echo "  $STEP. Edit $SKILL_DIR/SKILL.md"
echo "     - Update the description with trigger phrases"
echo "     - Define when to use this skill"
echo "     - Write the process steps"
echo "     - Add output principles and error handling"
echo ""
STEP=$((STEP + 1))
if [ "$WITH_REFERENCES" = true ]; then
    echo "  $STEP. Add reference files to $SKILL_DIR/references/"
    echo "     - Link with @references/filename.md from SKILL.md"
    echo ""
    STEP=$((STEP + 1))
fi
if [ "$WITH_SCRIPTS" = true ]; then
    echo "  $STEP. Add scripts to $SKILL_DIR/scripts/"
    echo "     - Make scripts executable: chmod +x scripts/*.sh"
    echo ""
    STEP=$((STEP + 1))
fi
echo "  $STEP. Validate the skill:"
echo "     $SCRIPT_DIR/validate-skill.sh $SKILL_NAME"
echo ""
STEP=$((STEP + 1))
echo "  $STEP. Test by invoking /$SKILL_NAME"
