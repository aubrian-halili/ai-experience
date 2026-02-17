---
name: pr
description: Use when the user asks to "create a PR", "open a pull request", "submit for review", "push and create PR", mentions "PR", "pull request", or needs help creating and submitting changes for code review.
argument-hint: "[optional: --draft, target branch, or PR title]"
disable-model-invocation: true
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

### 2. Generate PR Content

**Title** (priority order):
1. User-provided argument (auto-prefix ticket ID if missing)
2. Single commit message (if only one commit)
3. Branch name converted: `UN-1234-add-auth` → `UN-1234 Add auth`

**Title rules:** Max 72 chars, imperative mood, no period, ticket ID prefix

**Description template:**
```markdown
## Jira
<ticket-id from branch>

## Summary
<bullet points from commit messages>

## Test plan
<verification steps>
```

### 3. Push and Create PR

```bash
# Push branch if needed
git push -u origin $(git branch --show-current)

# Create PR (use HEREDOC for body)
gh pr create --title "<TICKET-ID> <title>" --body "$(cat <<'EOF'
## Jira
UN-1234

## Summary
- Bullet points from commits

## Test plan
- Verification steps
EOF
)"
```

**Variations:**
- Add `--draft` for work-in-progress
- Add `--base <branch>` for non-main target

## Response Format

```markdown
## Pull Request Created

**Ticket**: UN-1234
**Branch**: `UN-1234-add-user-auth` → `main`
**Title**: UN-1234 Add user authentication flow
**URL**: https://github.com/owner/repo/pull/123

### Summary
- Add login endpoint with JWT tokens
- Implement password hashing with bcrypt

### Next Steps
1. Wait for CI checks
2. Request review
3. Address feedback
```

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
| On main/master | "Cannot create PR from default branch" |
| No commits ahead | "No commits. Use `/commit` first" |
| Uncommitted changes | "Commit or stash changes first" |
| PR already exists | Show existing PR URL |
| Push rejected | "Run `git pull --rebase origin <branch>`" |
| No gh CLI | "Install from https://cli.github.com/" |
| No ticket ID | "Provide Jira ticket ID to continue" |

## Issue Linking

**Jira (auto-detected from branch):**
- `UN-1234-add-auth` → Extracts `UN-1234` for title and Jira section

**GitHub issues (auto-detected from commits):**
- `Closes #123` in commit → Added to PR description

## Quick Reference

```bash
# Basic PR
/pr

# Draft PR
/pr --draft

# Custom title
/pr "Add OAuth2 support"
```

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/commit` | Commit changes before creating PR |
| `/review` | Review a PR (yours or others) |
