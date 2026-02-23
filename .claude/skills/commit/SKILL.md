---
name: commit
description: Use when the user asks to "commit changes", "create a commit", "commit this", mentions "git commit", "commit message", or needs help with semantic commits or branch management.
argument-hint: "[optional commit message or scope]"
allowed-tools: Bash, Read, Grep, Glob
disable-model-invocation: true
---

Generate semantic commit messages following project conventions (see CLAUDE.md).

## Commit Philosophy

- **Atomic commits** — each commit should represent one logical change; split multi-concern changes into separate commits (see `@references/advanced-workflows.md`)
- **Semantic messages** — follow `<TICKET-ID> <type>(<scope>): <subject>` format; the subject should explain why, not what
- **Safety-first** — stage specific files by name, never `git add -A` or `.`; never stage sensitive files
- **User confirmation** — always present the proposed commit for review before executing; never commit without explicit approval
- **Hook compliance** — never skip pre-commit hooks with `--no-verify` unless explicitly requested; if hooks fail, fix the issue and create a NEW commit

## When to Use

### This Skill Is For

- Creating semantic commit messages
- Staging and committing changes

### Use a Different Approach When

- Creating a pull request → use `/pr`
- Advanced multi-commit workflows → see `@references/advanced-workflows.md`
- Generating changelog entries → see `@references/changelog.md`

## Input Classification

Determine commit workflow from `$ARGUMENTS`:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Full commit workflow | Steps 1-4; analyze all changes |
| Commit message text | Use as proposed message | Steps 1-4; skip message generation |
| Scope hint (e.g., `auth`) | Scope-focused commit | Steps 1-4; filter analysis to scope |
| `--amend` | Amend last commit | Steps 1-4; warn if already pushed |

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

Review current state:
- `git status` - Overall status
- `git diff --cached` - Already staged changes
- `git diff` - Unstaged changes
- `git log --oneline -5` - Recent commit history

Use `$ARGUMENTS` if provided (user's custom message or scope), otherwise generate appropriate commit message.

Format: `<TICKET-ID> <type>(<scope>): <subject>` (max 72 chars)

**Present to user:**
- Show **staged files** separately from **unstaged files**
- Warn if sensitive files are present (`.env`, `.env.*`, `credentials.json`, `*.pem`, `*.key`)
- Show the proposed commit message (with body if needed)
- Ask the user to review and confirm before proceeding
- If changes requested, regenerate and present again

### 3. Stage & Commit

**Only proceed after user approval.**

**Safety rules:**
- Stage specific files by name (never `git add -A` or `git add .`)
- Never stage sensitive files (`.env`, `.env.*`, `credentials.json`, `*.pem`, `*.key`)
- Never use `--no-verify` to skip hooks unless explicitly requested by user
- Use only these git commands: `status`, `diff`, `log`, `branch`, `add`, `commit`, `stash`

```bash
# Stage specific files
git add <file1> <file2>

# Commit with HEREDOC for multi-line messages
git commit -m "$(cat <<'EOF'
<TICKET-ID> <type>(<scope>): <subject>

<body if needed>

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### 4. Verify

After successful commit:
```bash
git status
git log --oneline -1
```

Show the result to the user to confirm the commit was created successfully.

## Output Principles

- **Staged vs unstaged clarity** — always show staged and unstaged files separately so the user knows exactly what will be committed
- **Sensitive file warnings** — flag `.env`, credentials, and key files prominently before they can be committed
- **Message preview** — show the complete commit message (subject + body) formatted exactly as it will appear in git log
- **Confirmation gate** — explicitly ask the user to approve before executing any git commands that modify state

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Analyze changes and generate commit message |
| `"fix login timeout"` | Use as basis for commit message, apply formatting |
| `auth` | Use as scope hint, analyze auth-related changes |
| `--amend` | Amend last commit with warning about pushed commits |

## Error Handling

| Scenario | Response |
|----------|----------|
| No changes detected | Show `git status`, suggest what to stage |
| Mixed change types | Recommend splitting into multiple commits |
| Unclear scope | Ask for clarification or suggest based on files |
| No ticket ID in branch | Ask user for ticket ID |
| On main/master branch | Ask for ticket ID + description to create branch |
| Pre-commit hook fails | Fix the issue, re-stage files, create a NEW commit (never amend) |
| Sensitive files detected | Warn user, ask if they should be added to `.gitignore` |
| User requests `--no-verify` | Confirm intent, warn about skipping hooks |

Never commit without user approval or stage files with `git add -A` — always stage specific files by name after review.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Review changes before committing |
| `/pr` | Create pull request after committing |
| `/explore` | Understand changes before deciding what to commit |
| `/clean-code` | Clean up code before committing |
