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

## Confidence Scoring Rubric

| Score | Meaning | Action |
|-------|---------|--------|
| **Below 80** | Unverified, low impact, or missing evidence | Do not report — note: a finding that feels "important" (score 75) still fails the gate without full evidence |
| **80+** | Verified with strong supporting evidence — real issue, confirmed impact | Report |

**Gate enforcement — a finding reaches 80 only when ALL of these are true:**
1. You can cite the exact `file:line` where the issue occurs (read the source file, not just the diff)
2. You ran `git blame -L <start>,<end> <file>` to confirm this is a new issue, not pre-existing
3. You can describe the concrete negative consequence if the issue is left unfixed

**Never flag TODOs the author already flagged.**

## Input Handling

Pass `--refactor` to perform a Clean Code & SOLID-focused review with Edit suggestions (e.g., `src/auth/ --refactor`).

## Specialized Review Passes

For large scopes (>10 files), dispatch `code-quality-reviewer` and `security-scanner` subagents.

## Process

**Branch point:** Local review → step 2. PR review → steps 1, 3.

### 1. Pre-flight (PR only)

Screen PR eligibility:
```bash
gh pr view <number> --json state,isDraft,author,labels
```

**Stop conditions:**
- PR is a draft → report and stop
- PR author is a bot (e.g., `dependabot`, `renovate`) → report and stop

### 2. Analyze Local Changes (Local only)

Apply gate enforcement, then present findings using the Local Changes template from `@references/templates.md`.

### 3. Analyze Pull Request (PR only)

```bash
gh pr view <number> --json title,body,author,baseRefName,headRefName,files,additions,deletions,changedFiles
gh pr diff <number>
gh pr view <number> --json reviews,comments
```

> **Important:** Run `gh pr diff` exactly as shown — it does not support `-- <file>` path filtering or any additional arguments. Retrieve the full diff once, then analyze relevant sections from the output.

Apply gate enforcement, then present findings using the Pull Request Review template from `@references/templates.md`.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/feature` | Return to implementation to address review findings |
