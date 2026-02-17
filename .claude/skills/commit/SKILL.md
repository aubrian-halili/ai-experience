---
name: commit
description: Use when the user asks to "commit changes", "create a commit", "commit this", mentions "git commit", "commit message", or needs help with semantic commits or branch management.
argument-hint: "[optional commit message or scope]"
disable-model-invocation: true
---

Generate semantic commit messages and manage branches following project conventions.

## When to Use

### This Skill Is For

- Creating semantic commit messages
- Staging and committing changes
- Branch creation and management
- Following git conventions from CLAUDE.md

### Use a Different Approach When

- Reviewing changes before commit → use `/review`
- Creating a pull request → use `/pr`
- Understanding what changed → check `git diff`
- Generating changelog → see `@references/changelog.md`
- Advanced multi-commit workflows → see `@references/advanced-workflows.md`

## Git Conventions

Follow conventions defined in project's CLAUDE.md for:
- Branch naming: `<JIRA-ID>-<feature-description>`
- Commit format: `<JIRA-ID> <type>(<scope>): <description>`

**Types**: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`

## Process

### 1. Pre-flight Checks

```bash
BRANCH=$(git branch --show-current)
TICKET_ID=$(echo "$BRANCH" | grep -oE '[A-Z]+-[0-9]+' | head -1)
```

**Stop conditions:**
- On `main`/`master` → Create feature branch first
- No ticket ID in branch → Ask user for ticket ID
- No changes → Nothing to commit

### 2. Analyze Changes

```bash
git status
git diff --cached
git diff
git log --oneline -5
```

### 3. Classify Changes

| Prefix | Use When | Example |
|--------|----------|---------|
| `feat:` | Adding new functionality | `UN-1234 feat: add user preferences API` |
| `fix:` | Fixing a bug | `UN-1234 fix: resolve null pointer in auth flow` |
| `docs:` | Documentation only | `UN-1234 docs: update API reference for v2` |
| `refactor:` | Code change without behavior change | `UN-1234 refactor: extract validation logic` |
| `test:` | Adding or modifying tests | `UN-1234 test: add coverage for edge cases` |
| `chore:` | Maintenance, deps, config | `UN-1234 chore: update dependencies` |

### 4. Generate Commit Message

Structure:
```
<ticket-id> <type>(<scope>): <subject>

<body>

<footer>
```

Rules:
- **Ticket ID**: Always prefix with Jira ticket ID extracted from branch name
- **Subject**: Imperative mood, no period, max 72 chars
- **Body**: Explain what and why (not how)
- **Footer**: Reference issues, breaking changes

### 5. Execute Commit

```bash
# Stage specific files (preferred - avoids sensitive files)
git add <file1> <file2>

# Commit with message using HEREDOC for proper formatting
git commit -m "$(cat <<'EOF'
<message>
EOF
)"
```

**Important:** Always prefer staging specific files over `git add -A` or `git add .`

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
```

## Protected Branches

- **Never commit directly to `main` or `master`**
- Always work on feature branches
- Feature branches must include Jira ticket ID prefix

**When on protected branch:**
1. Stop — do not commit
2. Ask for Jira ticket ID and feature description
3. Create new branch: `git checkout -b <JIRA-ID>-<feature-description>`
4. Then proceed with commit

## Branch Management

**Important:** Always ask the user for the Jira ticket ID before creating a branch.

```bash
# Format: <JIRA-ID>-<feature-description>
git checkout -b UN-1234-add-user-preferences

# Or from a specific base
git checkout -b UN-1234-add-user-preferences origin/main
```

## Error Handling

| Scenario | Response |
|----------|----------|
| No changes detected | Show `git status`, suggest what to stage |
| Mixed change types | Recommend splitting into multiple commits |
| Unclear scope | Ask for clarification or suggest based on files |
| No ticket ID in branch | Prompt: "No Jira ticket ID found. Please provide a ticket ID." |
| On main/master branch | Prompt: "Direct commits to `main`/`master` not allowed. Provide ticket ID to create branch." |

## Quick Reference

```bash
# Feature
git commit -m "UN-1234 feat(scope): add new capability"

# Bug fix
git commit -m "UN-1234 fix(scope): resolve specific issue"

# Chore
git commit -m "UN-1234 chore: update dependencies"
```

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Review changes before committing |
| `/pr` | Create pull request after committing |
