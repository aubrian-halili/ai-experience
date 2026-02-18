---
name: commit
description: Use when the user asks to "commit changes", "create a commit", "commit this", mentions "git commit", "commit message", or needs help with semantic commits or branch management.
argument-hint: "[optional commit message or scope]"
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Grep, Glob
---

Generate semantic commit messages following project conventions (see CLAUDE.md).

## When to Use

### This Skill Is For

- Creating semantic commit messages
- Staging and committing changes

### Use a Different Approach When

- Creating a pull request → use `/pr`
- Generating changelog → see `@references/changelog.md`
- Advanced multi-commit workflows → see `@references/advanced-workflows.md`

## Process

### 1. Pre-flight Checks

Extract branch and ticket ID:
```bash
BRANCH=$(git branch --show-current)
TICKET_ID=$(echo "$BRANCH" | grep -oE '[A-Z]+-[0-9]+' | head -1)
```

**Stop conditions:**
- On `main`/`master` → Ask for Jira ticket ID + feature description, create branch with `git checkout -b <JIRA-ID>-<description>`, then proceed
- No ticket ID in branch → Ask user for ticket ID
- No changes → Nothing to commit

### 2. Analyze & Present for Review

Review `git status`, `git diff --cached`, `git diff`, and recent commits (`git log --oneline -5`).

Use `$ARGUMENTS` if provided (user's custom message or scope), otherwise generate appropriate commit message.

Format: `<TICKET-ID> <type>(<scope>): <subject>` (max 72 chars)

**Present to user:**
- Show the files to be staged
- Show the proposed commit message (with body if needed)
- Ask the user to review and confirm before proceeding
- If changes requested, regenerate and present again

### 3. Stage & Commit

**Only proceed after user approval.**

```bash
# Stage specific files (never git add -A or git add .)
git add <file1> <file2>

# Commit with HEREDOC for multi-line messages
git commit -m "$(cat <<'EOF'
<TICKET-ID> <type>(<scope>): <subject>

<body if needed>

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## Error Handling

| Scenario | Response |
|----------|----------|
| No changes detected | Show `git status`, suggest what to stage |
| Mixed change types | Recommend splitting into multiple commits |
| Unclear scope | Ask for clarification or suggest based on files |
| No ticket ID in branch | Ask user for ticket ID |
| On main/master branch | Ask for ticket ID + description to create branch |
| Pre-commit hook fails | Fix the issue, re-stage files, create a NEW commit (never amend) |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Review changes before committing |
| `/pr` | Create pull request after committing |
