#!/bin/bash
# Validate a Claude Code skill's structure and frontmatter

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <skill-name>"
    echo ""
    echo "Validates a skill's SKILL.md structure and frontmatter"
    echo ""
    echo "Arguments:"
    echo "  skill-name    Name of the skill to validate"
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
SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"
SKILL_FILE="$SKILL_DIR/SKILL.md"

ERRORS=0
WARNINGS=0

error() {
    echo -e "${RED}✗ ERROR: $1${NC}"
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

pass() {
    echo -e "${GREEN}✓ $1${NC}"
}

echo "Validating skill: $SKILL_NAME"
echo "Path: $SKILL_FILE"
echo ""

# Check skill directory exists
if [ ! -d "$SKILL_DIR" ]; then
    error "Skill directory not found: $SKILL_DIR"
    echo ""
    echo -e "${RED}FAIL${NC} - Skill directory does not exist"
    exit 1
fi

# Check SKILL.md exists
if [ ! -f "$SKILL_FILE" ]; then
    error "SKILL.md not found in $SKILL_DIR"
    echo ""
    echo -e "${RED}FAIL${NC} - Missing SKILL.md"
    exit 1
fi
pass "SKILL.md exists"

# Check frontmatter starts with ---
if ! head -1 "$SKILL_FILE" | grep -q "^---$"; then
    error "SKILL.md must start with frontmatter (---)"
else
    pass "Frontmatter delimiter present"
fi

# Check frontmatter has closing ---
if ! sed -n '2,/^---$/p' "$SKILL_FILE" | tail -1 | grep -q "^---$"; then
    error "Frontmatter closing delimiter (---) not found"
else
    pass "Frontmatter properly closed"
fi

# Extract frontmatter content (compatible with macOS and Linux)
FRONTMATTER=$(awk 'NR==1{next} /^---$/{exit} {print}' "$SKILL_FILE")

# Check required field: name
if echo "$FRONTMATTER" | grep -q "^name:"; then
    FOUND_NAME=$(echo "$FRONTMATTER" | grep "^name:" | sed 's/name: *//')
    pass "Required field 'name' present: $FOUND_NAME"

    # Warn if name doesn't match directory
    if [ "$FOUND_NAME" != "$SKILL_NAME" ]; then
        warn "Skill name '$FOUND_NAME' doesn't match directory name '$SKILL_NAME'"
    fi
else
    error "Required field 'name' missing from frontmatter"
fi

# Check required field: description
if echo "$FRONTMATTER" | grep -q "^description:"; then
    pass "Required field 'description' present"
else
    error "Required field 'description' missing from frontmatter"
fi

# Check for placeholder text
if grep -q "\[skill-name\]\|\[trigger phrases\]\|\[argument placeholder\]" "$SKILL_FILE"; then
    warn "Template placeholders still present in SKILL.md"
fi

# Summary
echo ""
echo "----------------------------------------"
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}FAIL${NC} - $ERRORS error(s), $WARNINGS warning(s)"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}PASS with warnings${NC} - $WARNINGS warning(s)"
    exit 0
else
    echo -e "${GREEN}PASS${NC} - All checks passed"
    exit 0
fi
