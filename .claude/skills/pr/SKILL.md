---
name: pr
description: >-
  User asks to "create a PR", "open a pull request", "push and create PR",
  or mentions "pull request" in context of creating one.
  Not for: reviewing an existing PR (use /review), committing without pushing (use /commit).
argument-hint: "[optional: --major, --fe, --ready, target branch, or PR title]"
allowed-tools: Bash(git branch *, git log *, git status *, git rev-list *, git push *, gh repo *, gh pr *, acli *), Read, Grep, Glob
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`
**Recent commits:** !`git log --oneline -5`

Create pull requests with auto-generated titles and descriptions from commit history.

## PR Philosophy

- **User confirmation** — always present the complete PR details for review before creating; never push or open a PR without explicit approval
- **Convention compliance** — titles and descriptions follow project conventions (pr-conventions.md); ticket ID is always present
- **Safety-first** — never force push, never push to main, never skip divergence checks; ask before destructive actions
- **Commit-driven content** — PR title and description are generated from commit history, not invented; quality commits produce quality PRs

> **Iron Laws — never violate these:**
> 1. Never push or create a PR without explicit user approval
> 2. Never force push to any branch
> 3. Never create a PR from the default branch (`main`/`master`)
> 4. Always use the selected template verbatim for the PR body — never improvise sections

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
- No commits ahead → Use `/commit` first
- Uncommitted changes → Commit or stash first
- PR already exists → Show existing PR URL, status, and next steps (view: `gh pr view`, push more commits: `git push`, edit: `gh pr edit`)
- No ticket ID in branch → Ask user for ticket ID

### 2. Prepare & Present for Review

Use `$ARGUMENTS` if provided (handles `--ready`, custom title, or target branch). PRs are created as drafts by default (use `--ready` to skip draft mode).

**Title generation** (priority order):
1. User-provided title (auto-prefix ticket ID if missing)
2. Single commit → use its message directly (already convention-formatted from `/commit`)
3. Multiple commits → summarize with `<TICKET-ID> <type>(<scope>): <summary>`
4. Fallback: branch name converted `UN-1234-add-auth` → `UN-1234 feat: add auth`

Title format: `<TICKET-ID> <type>(<scope>): <description>` (max 72 chars, per pr-conventions.md)

**Body generation** — select template based on flags:

| Flags          | Template                                 |
|----------------|------------------------------------------|
| (none)         | @references/minor-template.md            |
| `--major`      | @references/major-template.md            |
| `--fe`         | @references/frontend-minor-template.md   |
| `--fe --major` | @references/frontend-major-template.md   |

**CRITICAL: The PR body MUST be constructed from the selected template file** Read the template file, copy its entire structure, then fill in the dynamic sections below from commit history:
- **Summary** — bullet points derived from commit messages
- **Jira** — ticket ID from branch name, linked to `https://qredab.atlassian.net/browse/<TICKET-ID>`
- **Breaking Changes** — "None" or list from commits
- **Test Plan** — verification steps relevant to the changes

**Present to user:**
- Show the full PR details: ticket ID, title, body, flags (draft by default, `--ready` to override, `--base <branch>`)
- Indicate which template was used (minor/major, and `(frontend)` when `--fe` is active) so the user can override with `--major` or `--fe` if needed
- Ask the user to review and confirm before proceeding
- If changes requested, regenerate and present again

### 3. Push & Create PR

**Only proceed after user approval.**

**Safety note:** If the remote branch exists and has diverged (e.g., after rebase), never use `git push --force` without explicit user confirmation.

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

PRs are created as drafts by default. Add `--ready` to skip draft mode, `--base <branch>` for non-main target, `--label <name>` to add labels.

### 4. Verify & Link

After successful PR creation:
```bash
gh pr view --json number,url,title,state
```

Show the user: PR number, URL, title, state, and next steps:
- Request reviews
- Monitor CI (draft PRs still trigger CI workflows)
- Mark ready for review: `gh pr ready`
- Convert back to draft: `gh pr ready --undo`

**Jira integration (optional):** If a Jira ticket ID was detected and acli is available, offer to transition the ticket status (e.g., to "In Review") using `acli jira workitem transition --key <ISSUE_KEY> --status "In Review"`. Always confirm with the user before changing ticket status.

## Output Principles

- **PR preview before creation** — present the complete PR (title, body, flags) for user review before pushing or creating
- **Convention-formatted title** — follows pr-conventions.md format (already loaded)
- **Template-driven body** — PR body is always constructed from the selected template file (never improvised); dynamic sections are filled from commits, static sections are copied verbatim
- **Actionable result** — after creation, show PR number, URL, and next steps (request reviews, monitor CI)

## Error Handling

| Scenario | Response |
|----------|----------|
| Push rejected | "Run `git pull --rebase origin <branch>`" or check for diverged history |
| Remote branch diverged | Never use `--force` without explicit user confirmation |
| No gh CLI | "Install from https://cli.github.com/" |
| gh auth failure | "Run `gh auth login` to authenticate" |
| Branch protection rules | "Push to a feature branch instead, or request access" |

Never force push or create a PR from the default branch — always verify branch state and user intent before pushing.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/jira` | Create Jira ticket before starting work |
| `/feature` | Implement features before creating PR |
| `/commit` | Commit changes before creating PR |
| `/review` | Review a PR (yours or others) |
| `/receiving-review` | Address review feedback on your PR |
| `/finish` | Decide what to do with the branch (PR, merge, park, or discard) |
