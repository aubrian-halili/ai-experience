---
name: pr
description: Use when the user asks to "create a PR", "open a pull request", "submit for review", "push and create PR", mentions "PR", "pull request", or needs help creating and submitting changes for code review.
argument-hint: "[optional: --draft, target branch, or PR title]"
disable-model-invocation: true
allowed-tools: Bash(git *, gh *), Read, Grep, Glob
---

Create pull requests with auto-generated titles and descriptions from commit history.

## When to Use

### This Skill Is For

- Creating pull requests from feature branches
- Generating PR titles and descriptions from commits
- Pushing branches and opening PRs in one step

### Use a Different Approach When

- Committing changes first → use `/commit`
- Reviewing an existing PR → use `/review`
- Draft PR workflows → see `@references/draft-workflow.md`

## Process

### 1. Pre-flight Checks

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
- PR already exists → Show existing PR URL
- No ticket ID in branch → Ask user for ticket ID

### 2. Create PR

Use `$ARGUMENTS` if provided (handles `--draft`, custom title, or target branch).

**Title generation** (priority order):
1. User-provided title (auto-prefix ticket ID if missing)
2. Single commit message (if only one commit)
3. Branch name converted: `UN-1234-add-auth` → `UN-1234 Add auth`

Title format: Max 72 chars, ticket ID prefix.

**Push and create:**

```bash
# Push branch if needed
git push -u origin $(git branch --show-current)

# Create PR with HEREDOC for body
gh pr create --title "<TICKET-ID> <title>" --body "$(cat <<'EOF'
## Jira
<TICKET-ID>

## Summary
- Bullet points from commit messages

## Test plan
- Verification steps
EOF
)"
```

Add `--draft` for work-in-progress, `--base <branch>` for non-main target.

Show the user: ticket, branch, title, URL, and next steps.

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Auto-generate title/description |
| `--draft` | Create as draft PR |
| Branch name | Use as target base branch |
| Text string | Use as PR title (ticket ID auto-prefixed) |

## Error Handling

| Scenario | Response |
|----------|----------|
| Push rejected | "Run `git pull --rebase origin <branch>`" |
| No gh CLI | "Install from https://cli.github.com/" |
| gh auth failure | "Run `gh auth login` to authenticate" |
| Branch protection rules | "Push to a feature branch instead, or request access" |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/jira` | Create Jira ticket before starting work |
| `/feature` | Plan feature before implementing |
| `/commit` | Commit changes before creating PR |
| `/review` | Review a PR (yours or others) |
