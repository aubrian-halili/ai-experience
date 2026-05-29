---
name: review
description: >-
  User asks for "code review", "review this PR", "review my changes",
  "review PR #123", "is this ready to merge", "refactor this", "clean up this code",
  "reduce complexity", mentions "SOLID", "code smells", or "technical debt".
  Not for: verifying completeness against a plan (use /verify).
  Not for: addressing PR review feedback (use /receiving-review).
argument-hint: "[file, PR number, URL, or component to review] [--refactor]"
allowed-tools: Bash(git *, gh *), Read, Grep, Glob, Agent
---

**Current branch:** !`git branch --show-current`
**Diff stats:** !`git diff --stat origin/main..HEAD 2>/dev/null || git diff --stat HEAD~1..HEAD`

ultrathink

## Reporting Threshold

Only report a finding where `git blame -L <start>,<end> <file>` confirms the issue is introduced by this change, not pre-existing.

## Input Handling

Pass `--refactor` to perform a Clean Code & SOLID-focused review with Edit suggestions (e.g., `src/auth/ --refactor`).

## Specialized Review Passes

For large scopes (>10 files), dispatch `code-quality-reviewer` and `security-scanner` subagents.

## Process

### 1. Pre-flight (PR only)

Screen PR eligibility:
```bash
gh pr view <number> --json state,isDraft,author,labels,headRefName
```

**Stop conditions:**
- PR is a draft → report and stop
- PR author is a bot (e.g., `dependabot`, `renovate`) → report and stop

**Fetch PR locally** (required for `git blame`):
- Refuse if working tree is dirty (`git status --porcelain` non-empty).
- If `suggestions/pr-<number>` already exists locally:
  - Fetch the latest PR head without updating the local branch: `git fetch origin "pull/<number>/head"`.
  - Check for local-only commits: `git log FETCH_HEAD..suggestions/pr-<number> --oneline`. If any exist, stop and report — do not overwrite local work.
  - Check if behind: `git log suggestions/pr-<number>..FETCH_HEAD --oneline`. If empty, branch is up to date; skip to checkout. Otherwise, fast-forward update: `git fetch origin "pull/<number>/head:suggestions/pr-<number>"`.
- Otherwise: `git fetch origin "pull/<number>/head:suggestions/pr-<number>"` — this creates a non-tracking local branch.
- Then: `git checkout suggestions/pr-<number>`.

### 2. Analyze Local Changes (Local only)

Present findings using the Local Changes template from `@references/templates.md`.

### 3. Analyze Pull Request (PR only)

```bash
gh pr view <number> --json title,body,author,baseRefName,headRefName,files,additions,deletions,changedFiles
gh pr diff <number>
gh pr view <number> --json reviews,comments
```

> **Important:** Run `gh pr diff` exactly as shown — it does not support `-- <file>` path filtering or any additional arguments.

Present findings using the Pull Request Review template from `@references/templates.md`.
