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
AGENTS="$(cd "$SKILLS/.." && pwd)/agents"

fail=0
used=$(mktemp)              # every reference file that some SKILL.md or agent resolves to
trap 'rm -f "$used"' EXIT

report() { printf '%s\n' "$1"; fail=1; }

# Reference files that are deliberately gitignored, so they are absent on a fresh
# clone and must not be reported as broken. Keep this list in sync with .gitignore.
is_untracked_ref() { [ "$1" = "database-overview.md" ]; }

# Resolve every reference path in a file. $2 is the directory that unqualified
# 'references/x.md' paths resolve against (the owning skill's dir, or .claude/agents).
check_refs() {
    local md=$1 default_dir=$2 errs
    errs=$(mktemp)
    grep -oEn '(~/)?(\.claude/skills/[a-z0-9-]+/)?references/[a-z0-9-]+\.md' "$md" |
    while IFS=: read -r lineno path; do
        local base target
        base=$(basename "$path")
        case "$path" in
            *.claude/skills/*)
                target="$SKILLS/$(sed -E 's|.*\.claude/skills/([a-z0-9-]+)/.*|\1|' <<<"$path")/references/$base" ;;
            *)  target="$default_dir/references/$base" ;;
        esac
        if [ -f "$target" ]; then
            printf '%s\n' "$target" >>"$used"
        elif is_untracked_ref "$base"; then
            printf '%s\n' "$target" >>"$used"   # gitignored cache; absent on a clean checkout
        else
            printf '%s\n' "$md:$lineno  broken reference -> $path"
        fi
    done > "$errs"
    if [ -s "$errs" ]; then cat "$errs"; fail=1; fi
    rm -f "$errs"
}

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
    check_refs "$md" "${dir%/}"
done

# --- agents: same reference contract, plus the frontmatter fields they share ---
# Agents point into a skill's references/ (database-explorer -> backoffice-database),
# so a rename there would otherwise break the agent silently.
for md in "$AGENTS"/*.md; do
    [ -e "$md" ] || continue
    agent=$(basename "$md" .md)

    fm=$(awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1' "$md")
    if [ -n "$fm" ]; then
        for field in name description; do
            grep -q "^$field:" <<<"$fm" || report "$md:1  frontmatter missing '$field:'"
        done
        declared=$(awk '/^name:/{print $2; exit}' <<<"$fm")
        [ "$declared" = "$agent" ] || report "$md:1  name '$declared' does not match filename '$agent'"
    else
        report "$md:1  frontmatter missing or malformed"
    fi

    check_refs "$md" "$AGENTS"
done

# --- orphans: a reference file no SKILL.md resolves to is dead weight or a typo elsewhere ---
for f in "$SKILLS"/*/references/*.md "$AGENTS"/references/*.md; do
    [ -e "$f" ] || continue
    grep -qxF "$f" "$used" || report "$f  orphaned — no SKILL.md references it"
done

if [ "$fail" -eq 0 ]; then
    echo "skill contracts OK ($(ls -d "$SKILLS"/*/ | wc -l | tr -d ' ') skills)"
fi
exit "$fail"
