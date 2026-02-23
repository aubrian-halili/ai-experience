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

ERRORS=0
WARNINGS=0
VERBOSE=false
VALIDATE_ALL=false

# Known tools list for validation
KNOWN_TOOLS="Bash Read Grep Glob Write Edit WebFetch WebSearch Skill Task AskUserQuestion EnterPlanMode ExitPlanMode TaskCreate TaskUpdate TaskList TaskGet TaskOutput TaskStop"

usage() {
    echo "Usage: $0 [OPTIONS] <skill-name>"
    echo ""
    echo "Validates a skill's SKILL.md structure and frontmatter"
    echo ""
    echo "Options:"
    echo "  --all         Validate all skills in .claude/skills/"
    echo "  --verbose     Show detailed output including passes"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "Arguments:"
    echo "  skill-name    Name of the skill to validate (not needed with --all)"
    echo ""
    echo "Example:"
    echo "  $0 code-review"
    echo "  $0 --all"
    echo "  $0 --verbose skill-creator"
    exit 1
}

error() {
    echo -e "${RED}✗ ERROR: $1${NC}"
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

pass() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${GREEN}✓ $1${NC}"
    fi
}

info() {
    if [ "$VERBOSE" = true ]; then
        echo "  $1"
    fi
}

# Validation functions

validate_file_exists() {
    local skill_file="$1"

    if [ ! -f "$skill_file" ]; then
        error "SKILL.md not found"
        return 1
    fi
    pass "SKILL.md exists"
    return 0
}

validate_frontmatter_delimiters() {
    local skill_file="$1"

    # Check frontmatter starts with ---
    if ! head -1 "$skill_file" | grep -q "^---$"; then
        error "SKILL.md must start with frontmatter (---)"
        return 1
    fi
    pass "Frontmatter delimiter present"

    # Check frontmatter has closing ---
    if ! sed -n '2,/^---$/p' "$skill_file" | tail -1 | grep -q "^---$"; then
        error "Frontmatter closing delimiter (---) not found"
        return 1
    fi
    pass "Frontmatter properly closed"

    return 0
}

validate_name_field() {
    local skill_file="$1"
    local skill_name="$2"
    local frontmatter="$3"

    if ! echo "$frontmatter" | grep -q "^name:"; then
        error "Required field 'name' missing from frontmatter"
        return 1
    fi

    local found_name=$(echo "$frontmatter" | grep "^name:" | sed 's/name: *//')
    pass "Required field 'name' present: $found_name"
    info "Name: $found_name"

    # Check name length (max 64 chars)
    local name_length=${#found_name}
    if [ $name_length -gt 64 ]; then
        error "Name exceeds 64 characters (current: $name_length). Shorten by $((name_length - 64)) characters"
    else
        pass "Name length OK ($name_length/64 chars)"
    fi

    # Check kebab-case pattern
    if ! echo "$found_name" | grep -qE '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'; then
        error "Name must be kebab-case (lowercase letters, numbers, hyphens only)"
    else
        pass "Name format is kebab-case"
    fi

    # Check for reserved words
    if echo "$found_name" | grep -qiE 'anthropic|claude'; then
        error "Name contains reserved word ('anthropic' or 'claude')"
    else
        pass "Name does not contain reserved words"
    fi

    # Check for XML tags
    if echo "$found_name" | grep -qE '<|>'; then
        error "Name contains XML tags (< or >)"
    else
        pass "Name does not contain XML tags"
    fi

    # Warn if name doesn't match directory
    if [ "$found_name" != "$skill_name" ]; then
        warn "Skill name '$found_name' doesn't match directory name '$skill_name'"
    fi

    return 0
}

validate_description_field() {
    local frontmatter="$1"

    if ! echo "$frontmatter" | grep -q "^description:"; then
        error "Required field 'description' missing from frontmatter"
        return 1
    fi
    pass "Required field 'description' present"

    # Extract description (handle potential multiline, though not recommended)
    local description=$(echo "$frontmatter" | sed -n '/^description:/,/^[a-z-]*:/p' | sed '$d' | sed 's/^description: *//' | tr '\n' ' ')
    if [ -z "$description" ]; then
        description=$(echo "$frontmatter" | grep "^description:" | sed 's/^description: *//')
    fi

    info "Description: ${description:0:80}..."

    # Check description length (max 1024 chars)
    local desc_length=${#description}
    if [ $desc_length -gt 1024 ]; then
        error "Description exceeds 1024 characters (current: $desc_length). Shorten by $((desc_length - 1024)) characters"
    else
        pass "Description length OK ($desc_length/1024 chars)"
    fi

    # Check for XML tags
    if echo "$description" | grep -qE '<|>'; then
        error "Description contains XML tags (< or >)"
    else
        pass "Description does not contain XML tags"
    fi

    return 0
}

validate_body_length() {
    local skill_file="$1"

    # Count lines excluding frontmatter
    local frontmatter_end=$(grep -n "^---$" "$skill_file" | sed -n '2p' | cut -d: -f1)
    local total_lines=$(wc -l < "$skill_file")
    local body_lines=$((total_lines - frontmatter_end))

    info "Body length: $body_lines lines"

    if [ $body_lines -gt 500 ]; then
        warn "SKILL.md body exceeds 500 lines ($body_lines). Consider moving content to references/"
    else
        pass "Body length OK ($body_lines/500 lines)"
    fi

    return 0
}

validate_recommended_sections() {
    local skill_file="$1"

    # Check for recommended sections
    if ! grep -q "^## When to Use" "$skill_file"; then
        warn "Recommended section '## When to Use' not found"
    else
        pass "Section '## When to Use' present"
    fi

    if ! grep -q "^## Process" "$skill_file"; then
        warn "Recommended section '## Process' not found"
    else
        pass "Section '## Process' present"
    fi

    if ! grep -q "^## Error Handling" "$skill_file"; then
        warn "Recommended section '## Error Handling' not found"
    else
        pass "Section '## Error Handling' present"
    fi

    return 0
}

validate_references() {
    local skill_file="$1"
    local skill_dir="$2"

    # Extract all @references/ mentions with actual filenames (must have .md extension)
    local refs=$(grep -o '@references/[a-zA-Z0-9_-]*\.md' "$skill_file" | sort -u || true)

    if [ -z "$refs" ]; then
        pass "No reference files to validate"
        return 0
    fi

    # Check if referenced files exist
    while IFS= read -r ref; do
        local ref_path=$(echo "$ref" | sed 's/@//')
        local full_path="$skill_dir/$ref_path"

        if [ ! -f "$full_path" ]; then
            warn "Referenced file not found: $ref"
        else
            pass "Reference exists: $ref"
        fi

        # Check for nested references (references from references)
        # Look for @references/*.md patterns (actual file references)
        if [ -f "$full_path" ]; then
            if grep -oq '@references/[a-zA-Z0-9_-]*\.md' "$full_path"; then
                warn "Nested reference detected in $ref (anti-pattern)"
            fi
        fi
    done <<< "$refs"

    # Check for orphaned files in references/ directory
    if [ -d "$skill_dir/references" ]; then
        for file in "$skill_dir/references"/*; do
            if [ -f "$file" ]; then
                local basename=$(basename "$file")
                if ! grep -q "@references/$basename" "$skill_file"; then
                    warn "Unreferenced file in references/: $basename"
                fi
            fi
        done
    fi

    return 0
}

validate_allowed_tools() {
    local frontmatter="$1"

    if ! echo "$frontmatter" | grep -q "^allowed-tools:"; then
        pass "No allowed-tools field (optional)"
        return 0
    fi

    local tools=$(echo "$frontmatter" | grep "^allowed-tools:" | sed 's/allowed-tools: *//')
    info "Allowed tools: $tools"

    # Split by comma and validate each tool
    IFS=',' read -ra TOOL_ARRAY <<< "$tools"
    for tool in "${TOOL_ARRAY[@]}"; do
        # Trim whitespace
        tool=$(echo "$tool" | xargs)

        # Check against known tools (basic validation)
        if ! echo "$KNOWN_TOOLS" | grep -qw "$tool"; then
            warn "Unknown tool '$tool' in allowed-tools (may be MCP tool)"
        fi
    done
    pass "Allowed-tools field validated"

    return 0
}

validate_placeholders() {
    local skill_file="$1"

    # Check only in frontmatter and first 20 lines after frontmatter (intro section)
    # This avoids false positives from example usage in documentation
    local frontmatter_end=$(grep -n "^---$" "$skill_file" | sed -n '2p' | cut -d: -f1)
    local check_until=$((frontmatter_end + 20))

    if head -n $check_until "$skill_file" | grep -q "\[skill-name\]\|\[trigger phrases\]\|\[argument placeholder\]"; then
        warn "Template placeholders still present in frontmatter or introduction"
    else
        pass "No template placeholders in critical sections"
    fi

    return 0
}

# Main validation function for a single skill
validate_skill() {
    local skill_name="$1"
    local skill_dir="$SKILLS_DIR/$skill_name"
    local skill_file="$skill_dir/SKILL.md"

    echo "Validating skill: $skill_name"
    if [ "$VERBOSE" = true ]; then
        echo "Path: $skill_file"
    fi
    echo ""

    # Check skill directory exists
    if [ ! -d "$skill_dir" ]; then
        error "Skill directory not found: $skill_dir"
        echo ""
        echo -e "${RED}FAIL${NC} - Skill directory does not exist"
        return 1
    fi

    # Validate file exists
    validate_file_exists "$skill_file" || {
        echo ""
        echo -e "${RED}FAIL${NC} - Missing SKILL.md"
        return 1
    }

    # Validate frontmatter delimiters
    validate_frontmatter_delimiters "$skill_file" || {
        echo ""
        echo -e "${RED}FAIL${NC} - Invalid frontmatter structure"
        return 1
    }

    # Extract frontmatter content
    local frontmatter=$(awk 'NR==1{next} /^---$/{exit} {print}' "$skill_file")

    # Run all validation checks
    validate_name_field "$skill_file" "$skill_name" "$frontmatter"
    validate_description_field "$frontmatter"
    validate_body_length "$skill_file"
    validate_recommended_sections "$skill_file"
    validate_references "$skill_file" "$skill_dir"
    validate_allowed_tools "$frontmatter"
    validate_placeholders "$skill_file"

    # Summary
    echo ""
    echo "----------------------------------------"
    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}FAIL${NC} - $ERRORS error(s), $WARNINGS warning(s)"
        return 1
    elif [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}PASS with warnings${NC} - $WARNINGS warning(s)"
        return 0
    else
        echo -e "${GREEN}PASS${NC} - All checks passed"
        return 0
    fi
}

# Validate all skills
validate_all_skills() {
    echo "Validating all skills in $SKILLS_DIR"
    echo ""

    local total_skills=0
    local passed_skills=0
    local warned_skills=0
    local failed_skills=0
    local total_errors=0
    local total_warnings=0

    for skill_dir in "$SKILLS_DIR"/*; do
        if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
            local skill_name=$(basename "$skill_dir")
            total_skills=$((total_skills + 1))

            # Reset counters for this skill
            ERRORS=0
            WARNINGS=0

            echo "═══════════════════════════════════════"
            validate_skill "$skill_name"
            local result=$?
            echo ""

            # Track results
            total_errors=$((total_errors + ERRORS))
            total_warnings=$((total_warnings + WARNINGS))

            if [ $result -eq 0 ]; then
                if [ $WARNINGS -gt 0 ]; then
                    warned_skills=$((warned_skills + 1))
                else
                    passed_skills=$((passed_skills + 1))
                fi
            else
                failed_skills=$((failed_skills + 1))
            fi
        fi
    done

    # Final summary
    echo "═══════════════════════════════════════"
    echo "SUMMARY"
    echo "═══════════════════════════════════════"
    echo "Total skills: $total_skills"
    echo -e "${GREEN}Passed: $passed_skills${NC}"
    echo -e "${YELLOW}Passed with warnings: $warned_skills${NC}"
    echo -e "${RED}Failed: $failed_skills${NC}"
    echo ""
    echo "Total errors: $total_errors"
    echo "Total warnings: $total_warnings"
    echo ""

    if [ $failed_skills -gt 0 ]; then
        echo -e "${RED}Overall: FAIL${NC}"
        exit 1
    elif [ $warned_skills -gt 0 ]; then
        echo -e "${YELLOW}Overall: PASS with warnings${NC}"
        exit 0
    else
        echo -e "${GREEN}Overall: PASS${NC}"
        exit 0
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            VALIDATE_ALL=true
            shift
            ;;
        --verbose)
            VERBOSE=true
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

# Main execution
if [ "$VALIDATE_ALL" = true ]; then
    validate_all_skills
else
    if [ -z "$SKILL_NAME" ]; then
        echo -e "${RED}Error: No skill name provided${NC}"
        echo ""
        usage
    fi

    validate_skill "$SKILL_NAME"
    exit $?
fi
