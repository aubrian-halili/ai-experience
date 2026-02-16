---
name: commit
description: Use when the user asks to "commit changes", "create a commit", "commit this", mentions "git commit", "commit message", or needs help with semantic commits, branch management, or changelog generation.
argument-hint: "[optional commit message or scope]"
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

## Git Conventions Reference

From CLAUDE.md:
- **Commits**: `UN-XXXX feat:`, `UN-XXXX fix:`, `UN-XXXX docs:`, `UN-XXXX refactor:`, `UN-XXXX test:`, `UN-XXXX chore:`
- **Branches**: `UN-XXXX-<feature-description>`

## Process

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
# Stage specific files
git add <file1> <file2>

# Or stage all changes
git add -A

# Commit with message
git commit -m "<message>"
```

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

## Branch Management

### Creating Feature Branches

```bash
# Format: UN-XXXX-<feature-description>
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
| No ticket ID in branch | Prompt user: "No Jira ticket ID found in branch name. Expected format: `UN-XXXX-<feature>`. Provide a ticket ID or continue without one?" |

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
