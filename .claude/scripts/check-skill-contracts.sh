#!/usr/bin/env bash
# Checks the structural contract every .claude/skills/<name>/SKILL.md is expected to hold.
#
# These invariants are cheap to break silently and expensive to discover mid-run: a renamed
# reference file breaks the skill that points at it only once a user has already invoked it.
# There is no test suite in this repo (see CLAUDE.md), so this is the check.
#
# Usage: check-skill-contracts.sh [skills-dir]    (default: the repo's .claude/skills)
set -uo pipefail

SKILLS=${1:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/../skills" && pwd)"}
[ -d "$SKILLS" ] || { echo "not a directory: $SKILLS" >&2; exit 2; }

fail=0
used=$(mktemp)              # every reference file that some SKILL.md resolves to
trap 'rm -f "$used"' EXIT

report() { printf '%s\n' "$1"; fail=1; }

for dir in "$SKILLS"/*/; do
    skill=$(basename "$dir")
    md="${dir}SKILL.md"
    [ -f "$md" ] || { report "$skill: no SKILL.md"; continue; }

    # --- frontmatter: the block between the first two '---' lines ---
    fm=$(awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1' "$md")
    [ -n "$fm" ] || { report "$md:1  frontmatter missing or malformed"; continue; }

    for field in name description allowed-tools; do
        grep -q "^$field:" <<<"$fm" || report "$md:1  frontmatter missing '$field:'"
    done

    # The skill is addressed by directory name; a mismatched 'name:' makes /<name> unroutable.
    declared=$(awk '/^name:/{print $2; exit}' <<<"$fm")
    [ "$declared" = "$skill" ] || report "$md:1  name '$declared' does not match directory '$skill'"

    # With 14 skills sharing trigger vocabulary, the 'Not for:' clause is what keeps routing
    # unambiguous. It belongs in the description, where the model reads it during selection.
    grep -q 'Not for:' <<<"$fm" || report "$md:1  description has no 'Not for:' disambiguation clause"

    # --- reference paths resolve ---
    # Matches 'references/x.md', optionally qualified as '~/.claude/skills/<other>/references/x.md'
    # for the cross-skill case (/review and /verify point at gate's references).
    grep -oEn '(~/\.claude/skills/[a-z0-9-]+/)?references/[a-z0-9-]+\.md' "$md" |
    while IFS=: read -r lineno path; do
        case "$path" in
            '~/.claude/skills/'*) owner=$(cut -d/ -f3 <<<"${path#\~/}") ;;
            *)                  owner=$skill ;;
        esac
        target="$SKILLS/$owner/references/$(basename "$path")"
        if [ -f "$target" ]; then
            printf '%s\n' "$target" >>"$used"
        else
            printf '%s\n' "$md:$lineno  broken reference -> $path"
        fi
    done > "$used.err"
    if [ -s "$used.err" ]; then cat "$used.err"; fail=1; fi
    rm -f "$used.err"
done

# --- orphans: a reference file no SKILL.md resolves to is dead weight or a typo elsewhere ---
for f in "$SKILLS"/*/references/*.md; do
    [ -e "$f" ] || continue
    grep -qxF "$f" "$used" || report "$f  orphaned — no SKILL.md references it"
done

if [ "$fail" -eq 0 ]; then
    echo "skill contracts OK ($(ls -d "$SKILLS"/*/ | wc -l | tr -d ' ') skills)"
fi
exit "$fail"
