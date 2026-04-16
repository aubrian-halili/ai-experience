---
name: pr
description: >-
  User asks to "create a PR", "open a pull request", "push and create PR",
  or mentions "pull request" in context of creating one.
  Not for: reviewing an existing PR (use /review).
argument-hint: "[optional: --major, --fe, --ready, target branch, or PR title]"
allowed-tools: Bash(git branch *, git log *, git diff *, git show *, git status *, git rev-list *, git push *, git fetch *, git remote *, gh repo *, gh pr *, acli *), Read, Grep, Glob
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`
**Recent commits:** !`git log --oneline -5`

Create pull requests with auto-generated titles and descriptions from commit history. Always use the selected template verbatim for the PR body — never improvise sections.

## Input Handling

Determine PR workflow from `$ARGUMENTS`:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Full PR workflow | Steps 1-4; auto-generate title and description (draft by default) |
| `--ready` | Non-draft PR | Steps 1-4; skip `--draft` flag |
| `--major` | Major PR template | Steps 1-4; use major template variant |
| `--fe` | Frontend PR template | Steps 1-4; use frontend template variant |
| `--fe --major` | Frontend major template | Steps 1-4; use frontend-major template |
| PR title text | Custom title | Steps 1-4; use provided title (auto-prefix ticket ID) |
| Branch name | Target base branch | Steps 1-4; use as `--base` argument |
| `--label <name>` | Labeled PR | Steps 1-4; add label to PR |

## Process

### 1. Pre-flight Checks

Parse `$ARGUMENTS` for flags (`--major`, `--fe`, `--ready`, `--base`, `--label`) and gather branch state:

```bash
BRANCH=$(git branch --show-current)
TICKET_ID=$(echo "$BRANCH" | grep -oE '[A-Z]+-[0-9]+' | head -1)
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q '.defaultBranchRef.name' 2>/dev/null || echo "main")
COMMITS_AHEAD=$(git rev-list --count "origin/$DEFAULT_BRANCH..HEAD" 2>/dev/null || echo "0")
UNCOMMITTED=$(git status --porcelain)
EXISTING_PR=$(gh pr list --head "$BRANCH" --json number,url --jq '.[0].url // empty')
```

**Stop conditions:**
- On `main`/`master` → Cannot create PR from default branch
- No commits ahead → Commit changes first
- PR already exists → Show existing PR URL, status, and next steps (view: `gh pr view`, push more commits: `git push`, edit: `gh pr edit`)
- No ticket ID in branch → Ask user for ticket ID

### 2. Prepare & Present for Review

Use `$ARGUMENTS` if provided (handles `--ready`, custom title, or target branch). PRs are created as drafts by default (use `--ready` to skip draft mode).

**Title generation** (priority order):
1. User-provided title (auto-prefix ticket ID if missing)
2. Single commit → use its message directly
3. Multiple commits → summarize with `<TICKET-ID> <type>(<scope>): <summary>`
4. Fallback: branch name converted `UN-1234-add-auth` → `UN-1234 feat: add auth`

**Body generation** — select template based on flags:

| Flags          | Template                                 |
|----------------|------------------------------------------|
| (none)         | @references/minor-template.md            |
| `--major`      | @references/major-template.md            |
| `--fe`         | @references/frontend-minor-template.md   |
| `--fe --major` | @references/frontend-major-template.md   |

**CRITICAL: The PR body MUST be constructed from the selected template file.** Read the template file and include **every section, checkbox, and line** — do not omit or summarize any part of the template. Fill in dynamic sections from commit history; copy all other sections verbatim with checkboxes intact. Check off only the items that apply.

**Template completeness check:** Before presenting, verify the generated body contains every `## ` heading from the selected template file. If any heading is missing, re-read the template and add the missing section before proceeding.

**Present to user:**
- Show the full PR details: ticket ID, title, body, flags (draft by default, `--ready` to override, `--base <branch>`)
- Indicate which template was used (minor/major, and `(frontend)` when `--fe` is active) so the user can override with `--major` or `--fe` if needed
- Ask the user to review and confirm before proceeding

### 3. Push & Create PR

```bash
# Push branch if needed (check if remote exists first)
git push -u origin $(git branch --show-current)

# Create PR as draft by default (use body as previewed in Step 2)
# Omit --draft only if user passed --ready flag
gh pr create --draft --title "<TICKET-ID> <type>(<scope>): <description>" --body "$(cat <<'EOF'
<body from Step 2>
EOF
)"
```

### 4. Verify & Link

After successful PR creation:
```bash
gh pr view --json number,url,title,state
```

**Jira integration (optional):** If a Jira ticket ID was detected and acli is available, offer to transition the ticket status (e.g., to "In Review") using `acli jira workitem transition --key <ISSUE_KEY> --status "In Review"`. Always confirm with the user before changing ticket status.
