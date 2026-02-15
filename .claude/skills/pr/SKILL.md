---
name: pr
description: Use when the user asks to "create a PR", "open a pull request", "submit for review", "push and create PR", mentions "PR", "pull request", or needs help creating and submitting changes for code review.
argument-hint: "[optional: --draft, target branch, or PR title]"
---

Create pull requests with auto-generated titles and descriptions from commit history.

## When to Use

### This Skill Is For

- Creating pull requests from feature branches
- Generating PR titles and descriptions from commits
- Pushing branches and opening PRs in one step
- Creating draft PRs for work-in-progress

### Use a Different Approach When

- Committing changes first → use `/commit`
- Reviewing an existing PR → use `/review`
- Planning a feature before implementation → use `/feature`

## Process

### 1. Pre-flight Checks

```bash
# Get current branch
git branch --show-current

# Verify not on default branch
git rev-parse --abbrev-ref HEAD

# Check for uncommitted changes
git status --porcelain

# Count commits ahead of main
git rev-list --count origin/main..HEAD
```

**Stop conditions:**
- On `main` or `master` → Cannot create PR from default branch
- No commits ahead → No commits to create PR. Use `/commit` first
- Uncommitted changes → Commit or stash changes first

### 2. Gather Context

```bash
# Get commits for this branch
git log origin/main..HEAD --oneline

# Get commit messages for description
git log origin/main..HEAD --pretty=format:"- %s"

# Get branch name for title inference
git branch --show-current

# Check if branch tracks remote
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null

# Check for existing PR
gh pr list --head $(git branch --show-current) --json number,url,state
```

### 3. Generate PR Title

**Priority order:**
1. User-provided title from argument
2. Derive from single commit message (if only one commit)
3. Derive from branch name (convert `aubrian/add-user-auth` → "Add user auth")

**Title rules:**
- Max 72 characters
- Imperative mood ("Add feature" not "Added feature")
- No period at end

### 4. Generate PR Description

**Structure:**

```markdown
## Summary
<bullet points derived from commit messages>

## Test plan
<verification steps - infer from changes or ask user>

---
Generated with Claude Code
```

**Enhancements:**
- Detect `Closes #N`, `Fixes #N` in commits → add to description
- Detect issue references in branch name (e.g., `issue-123`) → link issue

### 5. Push Branch (If Needed)

```bash
# Check if remote tracking exists
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null

# Push with upstream tracking if needed
git push -u origin $(git branch --show-current)
```

### 6. Create Pull Request

```bash
# Standard PR
gh pr create --title "<title>" --body "<description>"

# Draft PR (when --draft argument provided)
gh pr create --title "<title>" --body "<description>" --draft

# With specific base branch
gh pr create --title "<title>" --body "<description>" --base <target-branch>
```

## Response Format

```markdown
## Pull Request Created

**Branch**: `feature-branch` → `main`
**Title**: Add user authentication flow
**URL**: https://github.com/owner/repo/pull/123

### Summary

- Add login endpoint with JWT tokens
- Implement password hashing with bcrypt
- Add rate limiting to auth endpoints

### Status

| Check | Status |
|-------|--------|
| Branch pushed | ✅ |
| PR created | ✅ |
| Draft mode | ❌ |

### Next Steps

1. Wait for CI checks to pass
2. Request review from team
3. Address any feedback

---

Use `/review 123` to self-review before requesting others.
```

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Create PR with auto-generated title/description |
| `--draft` | Create as draft PR |
| Branch name (e.g., `develop`) | Use as target base branch |
| Text string | Use as PR title |

**Examples:**
- `/pr` → Auto-generate everything
- `/pr --draft` → Create draft PR
- `/pr develop` → Target `develop` instead of `main`
- `/pr Add OAuth2 support` → Use as PR title

## Error Handling

| Scenario | Response |
|----------|----------|
| On main/master | "Cannot create PR from default branch. Create a feature branch first with `git checkout -b <branch-name>`" |
| No commits ahead | "No commits to create PR. Use `/commit` first to create commits" |
| Uncommitted changes | "You have uncommitted changes. Commit or stash them first" |
| Branch already has PR | Show existing PR URL: "PR already exists: <url>" |
| Push rejected | "Push rejected. Try `git pull --rebase origin <branch>` to sync" |
| No gh CLI | "GitHub CLI (gh) not found. Install from https://cli.github.com/" |
| Not authenticated | "Not authenticated with GitHub. Run `gh auth login`" |

## Issue Linking

**Auto-detect from commits:**
```
feat: add login flow

Closes #123
```
→ Adds "Closes #123" to PR description

**Auto-detect from branch:**
- `aubrian/issue-123-add-auth` → Links issue #123
- `fix-456` → Links issue #456

## Draft PR Workflow

Use `--draft` for:
- Work-in-progress needing early feedback
- Changes not ready for merge
- Triggering CI before final review

```bash
# Create draft
gh pr create --draft --title "WIP: Add auth" --body "..."

# Mark ready when done
gh pr ready
```

## Quick Reference

```bash
# Basic PR creation
/pr

# Draft PR
/pr --draft

# With custom title
/pr "feat: Add user authentication"

# Target different base
/pr develop

# Combine options
/pr --draft develop
```

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/commit` | Need to commit changes before creating PR |
| `/review` | Want to review a PR (yours or others) |
| `/feature` | Planning what to build before implementing |
