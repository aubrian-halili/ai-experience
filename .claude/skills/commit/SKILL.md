---
name: commit
description: Use when the user asks to "commit changes", "create a commit", "commit this", mentions "git commit", "commit message", or needs help with semantic commits, branch management, or changelog generation.
argument-hint: "[optional commit message or scope]"
disable-model-invocation: true
---

Generate semantic commit messages, manage branches, and maintain changelog following project conventions.

## When to Use

### This Skill Is For

- Creating semantic commit messages
- Staging and committing changes
- Branch creation and management
- Generating changelog entries
- Following git conventions from CLAUDE.md

### Use a Different Approach When

- Reviewing changes before commit → use `/review`
- Creating a pull request → use `/pr`
- Understanding what changed → check `git diff`
- Committing directly to main/master → create a feature branch first

## Git Conventions Reference

From CLAUDE.md:

### Branch Naming

Branches must be prefixed with the Jira ticket ID:

`<JIRA-ID>-<feature-description>`

Example: `UN-1234-add-user-auth`

- Always ask for the Jira ticket ID before creating a new branch
- Never create a branch without the Jira ticket ID prefix

### Commit Messages

Every commit message must start with the Jira ticket ID:

`<JIRA-ID> <type>(<scope>): <description>`

- Extract the Jira ticket ID from the current branch name — do not ask the user for it
- If the branch name does not contain a Jira ticket ID, ask for one before committing
- Never create a commit without the Jira ticket ID prefix

**Types**: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`

## Process

### 0. Check Current Branch

```bash
# Get current branch name
BRANCH=$(git branch --show-current)

# Check if on protected branch
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  echo "⚠️  Cannot commit directly to $BRANCH branch"
  echo "Create a new branch first: git checkout -b <JIRA-ID>-<feature-description>"
  exit 1
fi
```

**Important:** Direct commits to `main` or `master` are not allowed. If on a protected branch:
1. Ask for the Jira ticket ID
2. Create a new branch with format: `<JIRA-ID>-<feature-description>`
3. Then proceed with the commit

### 1. Analyze Changes

```bash
# Check current status
git status

# View staged changes
git diff --cached

# View unstaged changes
git diff

# View recent commits for style reference
git log --oneline -5

# Extract Jira ticket ID from branch name
BRANCH=$(git branch --show-current)
TICKET_ID=$(echo "$BRANCH" | grep -oE '[A-Z]+-[0-9]+' | head -1)
# If TICKET_ID is empty, prompt user for ticket ID or note its absence
```

### 2. Classify Changes

| Prefix | Use When | Example |
|--------|----------|---------|
| `feat:` | Adding new functionality | `UN-1234 feat: add user preferences API` |
| `fix:` | Fixing a bug | `UN-1234 fix: resolve null pointer in auth flow` |
| `docs:` | Documentation only | `UN-1234 docs: update API reference for v2` |
| `refactor:` | Code change without behavior change | `UN-1234 refactor: extract validation logic` |
| `test:` | Adding or modifying tests | `UN-1234 test: add coverage for edge cases` |
| `chore:` | Maintenance, deps, config | `UN-1234 chore: update dependencies` |

### 3. Generate Commit Message

Structure:
```
<ticket-id> <type>(<scope>): <subject>

<body>

<footer>
```

Rules:
- **Ticket ID**: Always prefix with Jira ticket ID extracted from branch name (e.g., `UN-1234`)
- **Subject**: Imperative mood, no period, max 72 chars
- **Body**: Explain what and why (not how)
- **Footer**: Reference issues, breaking changes

### 4. Execute Commit

```bash
# Stage specific files (preferred - avoids sensitive files)
git add <file1> <file2>

# Avoid: git add -A or git add . (can include .env, credentials, large binaries)

# Commit with message using HEREDOC for proper formatting
git commit -m "$(cat <<'EOF'
<message>
EOF
)"
```

**Important:**
- Always prefer staging specific files over `git add -A` or `git add .`
- Use HEREDOC format for multi-line commit messages to ensure correct formatting

## Response Format

```markdown
## Commit Recommendation

### Changes Detected

| File | Status | Type |
|------|--------|------|
| `src/api/users.ts` | Modified | feat |
| `tests/api/users.test.ts` | Added | test |

### Suggested Commit

**Ticket**: `UN-1234`
**Type**: `feat`
**Scope**: `api`
**Subject**: add user preferences endpoint

**Full Message**:
```
UN-1234 feat(api): add user preferences endpoint

- Add GET/PUT endpoints for user preferences
- Include validation for preference values
- Add rate limiting to prevent abuse

Closes #123
```

### Commands

```bash
git add src/api/users.ts tests/api/users.test.ts
git commit -m "UN-1234 feat(api): add user preferences endpoint

- Add GET/PUT endpoints for user preferences
- Include validation for preference values
- Add rate limiting to prevent abuse

Closes #123"
```

### Alternative Messages

If you prefer a different style:

1. `UN-1234 feat: add user preferences API`
2. `UN-1234 feat(users): implement preferences management`
```

## Protected Branches

### Policy
- **Never commit directly to `main` or `master`**
- Always work on feature branches
- Feature branches must include Jira ticket ID prefix

### Workflow When on Protected Branch

If the current branch is `main` or `master`:

1. **Stop** — do not commit
2. **Ask** for Jira ticket ID and feature description
3. **Create** new branch: `git checkout -b <JIRA-ID>-<feature-description>`
4. **Then** proceed with staging and committing

## Branch Management

### Creating Feature Branches

**Important:** Always ask the user for the Jira ticket ID before creating a branch. Never create a branch without the ticket ID prefix.

```bash
# Format: <JIRA-ID>-<feature-description>
# Example: UN-1234-add-user-preferences

# First, ask: "What is the Jira ticket ID for this branch?"
# Then create the branch with the ticket ID prefix:
git checkout -b UN-1234-add-user-preferences

# Or from a specific base
git checkout -b UN-1234-add-user-preferences origin/main
```

### Branch Naming Examples

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `UN-XXXX-add-<feature>` | `UN-1234-add-dark-mode` |
| Fix | `UN-XXXX-fix-<issue>` | `UN-5678-fix-login-redirect` |
| Refactor | `UN-XXXX-refactor-<scope>` | `UN-9012-refactor-auth-flow` |

## Changelog Generation

### Format

```markdown
## [Version] - YYYY-MM-DD

### Added
- New feature description (#PR)

### Changed
- Modified behavior description (#PR)

### Fixed
- Bug fix description (#PR)

### Removed
- Removed feature description (#PR)
```

### Generate from Commits

```bash
# List commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Format for changelog
git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"- %s" --no-merges
```

## Multi-Commit Workflows

### Atomic Commits

When changes span multiple concerns:

```bash
# Commit 1: Infrastructure change
git add src/config/
git commit -m "UN-1234 chore: update database configuration"

# Commit 2: Feature implementation
git add src/services/ src/api/
git commit -m "UN-1234 feat: add user preferences service"

# Commit 3: Tests
git add tests/
git commit -m "UN-1234 test: add preferences service coverage"
```

### Squash Before PR

```bash
# Interactive rebase to squash
git rebase -i HEAD~3

# Or squash merge when merging PR
```

## Error Handling

| Scenario | Response |
|----------|----------|
| No changes detected | Show `git status`, suggest what to stage |
| Mixed change types | Recommend splitting into multiple commits |
| Unclear scope | Ask for clarification or suggest based on files |
| Large changeset | Recommend breaking into atomic commits |
| No ticket ID in branch | Prompt user: "No Jira ticket ID found in branch name. Expected format: `UN-XXXX-<feature>`. Please provide a ticket ID to continue." Never commit without ticket ID. |
| On main/master branch | Prompt: "Direct commits to `main`/`master` are not allowed. Please provide a Jira ticket ID and feature description to create a new branch." Then create branch with `git checkout -b <JIRA-ID>-<feature>` before committing. |

## Quick Reference

### Common Commit Patterns

```bash
# Feature
git commit -m "UN-1234 feat(scope): add new capability"

# Bug fix
git commit -m "UN-1234 fix(scope): resolve specific issue"

# Documentation
git commit -m "UN-1234 docs: update README with examples"

# Refactoring
git commit -m "UN-1234 refactor(scope): improve code structure"

# Tests
git commit -m "UN-1234 test(scope): add missing test coverage"

# Maintenance
git commit -m "UN-1234 chore: update dependencies"
```

### Breaking Changes

```
UN-1234 feat(api)!: change response format

BREAKING CHANGE: Response now returns array instead of object
```

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Review changes before committing |
| `/pr` | Create pull request after committing |
| `/feature` | Plan feature before implementing |
