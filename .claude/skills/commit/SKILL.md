---
name: commit
description: >-
  User asks to "commit", "create a commit", "commit my changes", or mentions "git commit".
  Not for: creating a PR (use /pr) or pushing changes (use /pr).
argument-hint: "[optional commit message or scope]"
allowed-tools: Bash(git *), Read, Grep, Glob
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`
**Recent commits:**
!`git log --oneline -3`

Generate semantic commit messages following project conventions (see CLAUDE.md).

## Commit Philosophy

- **Atomic commits** — each commit should represent one logical change; split multi-concern changes into separate commits (see `@references/advanced-workflows.md`)
- **Semantic messages** — follow `<TICKET-ID> <type>(<scope>): <subject>` format; the subject should explain why, not what
- **Safety-first** — stage specific files by name, never `git add -A` or `.`; never stage sensitive files
- **User confirmation** — always present the proposed commit for review before executing; never commit without explicit approval
- **Hook compliance** — never skip pre-commit hooks with `--no-verify` unless explicitly requested; if hooks fail, fix the issue and create a NEW commit

## Iron Laws

> - NEVER stage with `git add -A` or `git add .`
> - NEVER skip pre-commit hooks
> - NEVER commit without user approval
> - ONE logical change per commit — split if mixed

## Input Handling

Determine commit workflow from `$ARGUMENTS`:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Full commit workflow | Steps 1-4; analyze all changes |
| Commit message text | Use as proposed message | Steps 1-4; skip message generation |
| Scope hint (e.g., `auth`) | Scope-focused commit | Steps 1-4; filter analysis to scope |
| `--amend` | Amend last commit | Steps 1-4; warn if already pushed |

## Process

### 1. Pre-flight Checks

Extract ticket ID from branch name (pre-loaded above) using `grep -oE '[A-Z]+-[0-9]+'`.

**Stop conditions:** Follow branch/ticket rules from git-conventions.md — on `main`/`master` create a branch first; no ticket ID → ask user; no changes → nothing to commit.

### 2. Analyze & Present for Review

Review current state:
- `git status` - Overall status
- `git diff --cached` - Already staged changes
- `git diff` - Unstaged changes
- `git log --oneline -5` - Recent commit history

Use `$ARGUMENTS` if provided (user's custom message or scope), otherwise generate appropriate commit message.

Follow commit message format from git-conventions.md (already loaded). Subject line max 72 chars.

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

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
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
| `/review --refactor` | Clean up code before committing |
| `/jira` | Look up or update Jira ticket details |
