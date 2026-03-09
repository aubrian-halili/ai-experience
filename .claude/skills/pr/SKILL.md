---
name: pr
description: >-
  TRIGGER when: user asks to "create a PR", "open a pull request", "push and create PR", "submit for
  review", "open a PR", mentions "pull request" or "PR" in context of creating one.
  DO NOT TRIGGER when: user asks to review an existing PR (use /review) or to commit without pushing
  (use /commit).
argument-hint: "[optional: --draft, target branch, or PR title]"
allowed-tools: Bash(git *, gh *), Read, Grep, Glob, mcp__atlassian__getJiraIssue, mcp__atlassian__transitionJiraIssue
---

Create pull requests with auto-generated titles and descriptions from commit history.

## PR Philosophy

- **User confirmation** — always present the complete PR details for review before creating; never push or open a PR without explicit approval
- **Convention compliance** — titles and descriptions follow project conventions (pr-conventions.md); ticket ID is always present
- **Safety-first** — never force push, never push to main, never skip divergence checks; ask before destructive actions
- **Commit-driven content** — PR title and description are generated from commit history, not invented; quality commits produce quality PRs

## When to Use

### This Skill Is For

- Creating pull requests from feature branches
- Generating PR titles and descriptions from commits
- Pushing branches and opening PRs in one step

### Use a Different Approach When

- Committing changes first → use `/commit`
- Reviewing an existing PR → use `/review`
- Draft PR workflows → see `@references/draft-workflow.md`

## Input Classification

Determine PR workflow from `$ARGUMENTS`:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Full PR workflow | Steps 1-4; auto-generate title and description |
| `--draft` | Draft PR | Steps 1-4; add `--draft` flag |
| PR title text | Custom title | Steps 1-4; use provided title (auto-prefix ticket ID) |
| Branch name | Target base branch | Steps 1-4; use as `--base` argument |
| `--label <name>` | Labeled PR | Steps 1-4; add label to PR |

## Process

### 1. Pre-flight Checks

Parse `$ARGUMENTS` for flags (`--draft`, `--base`, `--label`) and gather branch state:

```bash
BRANCH=$(git branch --show-current)
TICKET_ID=$(echo "$BRANCH" | grep -oE '[A-Z]+-[0-9]+' | head -1)
COMMITS_AHEAD=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo "0")
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

Use `$ARGUMENTS` if provided (handles `--draft`, custom title, or target branch).

**Title generation** (priority order):
1. User-provided title (auto-prefix ticket ID if missing)
2. Single commit → use its message directly (already convention-formatted from `/commit`)
3. Multiple commits → summarize with `<TICKET-ID> <type>(<scope>): <summary>`
4. Fallback: branch name converted `UN-1234-add-auth` → `UN-1234 feat: add auth`

Title format: `<TICKET-ID> <type>(<scope>): <description>` (max 72 chars, per pr-conventions.md)

**Body generation:**
```
## Jira
<TICKET-ID>

## Summary
- Bullet points from commit messages

## Breaking Changes
- None / List breaking changes

## Test Plan
- Verification steps
```

**Present to user:**
- Show the full PR details: ticket ID, title, body, flags (`--draft`, `--base <branch>`)
- Ask the user to review and confirm before proceeding
- If changes requested, regenerate and present again

### 3. Push & Create PR

**Only proceed after user approval.**

**Safety note:** If the remote branch exists and has diverged (e.g., after rebase), never use `git push --force` without explicit user confirmation.

```bash
# Push branch if needed (check if remote exists first)
git push -u origin $(git branch --show-current)

# Create PR with HEREDOC for body
gh pr create --title "<TICKET-ID> <type>(<scope>): <description>" --body "$(cat <<'EOF'
## Jira
<TICKET-ID>

## Summary
- Bullet points from commit messages

## Breaking Changes
- None / List breaking changes

## Test Plan
- Verification steps
EOF
)"
```

Add `--draft` for work-in-progress, `--base <branch>` for non-main target, `--label <name>` to add labels.

### 4. Verify & Link

After successful PR creation:
```bash
gh pr view --json number,url,title,state
```

Show the user: PR number, URL, title, state, and next steps (e.g., request reviews, monitor CI).

**Jira integration (optional):** If a Jira ticket ID was detected and the Atlassian MCP is available, offer to transition the ticket status (e.g., to "In Review") using `mcp__atlassian__transitionJiraIssue`. Always confirm with the user before changing ticket status.

## Output Principles

- **PR preview before creation** — present the complete PR (title, body, flags) for user review before pushing or creating
- **Convention-formatted title** — `<TICKET-ID> <type>(<scope>): <description>` with max 72 chars, per pr-conventions.md
- **Structured body** — every PR body includes Jira reference, Summary, Breaking Changes, and Test Plan sections
- **Actionable result** — after creation, show PR number, URL, and next steps (request reviews, monitor CI)

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Auto-generate title and description |
| `--draft` | Create as draft PR |
| PR title text | Use as PR title (ticket ID auto-prefixed) |
| Branch name | Use as target base branch with `--base` |
| `--label <name>` | Add label(s) to the PR |

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
| `/feature` | Plan feature before implementing |
| `/commit` | Commit changes before creating PR |
| `/review` | Review a PR (yours or others) |
| `/explore` | Understand changes before creating PR |
