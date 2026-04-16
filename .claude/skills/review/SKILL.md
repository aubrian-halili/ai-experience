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

## Rationalization Guard

| Excuse | Reality |
|--------|---------|
| "The confidence gate is too strict — I'll report it anyway" | The gate exists to protect signal-to-noise ratio; below 80 means insufficient evidence |
| "Skipping the specialized passes, the diff is small" | The threshold is >10 files for parallel agents, not for skipping passes entirely |

### Confidence Scoring Rubric

| Score | Meaning | Action |
|-------|---------|--------|
| **Below 80** | Unverified, low impact, or missing evidence | Do not report — note: a finding that feels "important" (score 75) still fails the gate without full evidence |
| **80+** | Verified with strong supporting evidence — real issue, confirmed impact | Report |

**Gate enforcement — a finding reaches 80 only when ALL of these are true:**
1. You can cite the exact `file:line` where the issue occurs (read the source file, not just the diff)
2. You ran `git blame -L <start>,<end> <file>` to confirm this is a new issue, not pre-existing
3. You can describe the concrete negative consequence if the issue is left unfixed

If any of these are missing, score the finding below 80 regardless of how "obvious" it seems.

### Do Not Flag

Exclude regardless of confidence:

1. **Out-of-scope missing features**
2. **TODOs the author already flagged**

## Input Handling

Pass `--refactor` to perform a Clean Code & SOLID-focused review with Edit suggestions (e.g., `src/auth/ --refactor`).

## Specialized Review Passes

When the review scope is large (>10 files) or the user requests a thorough review, dispatch targeted subagents: `code-quality-reviewer` for quality dimensions and `security-scanner` for the security pass.

## Process

**Branch point:** Local review → steps 1–3, 6. PR review → steps 1, 4–6.

### 1. Pre-flight

- For PR reviews: verify `gh` is authenticated: `gh auth status`
- For PR reviews: screen PR eligibility before proceeding:
  ```bash
  gh pr view <number> --json state,isDraft,author,labels
  ```

**Stop conditions:**
- No local changes found (for local review) → report and suggest specifying a file or PR number
- PR review requested but `gh` not authenticated → provide `gh auth login` instructions and stop
- PR is a draft → report draft status and stop (unless user explicitly requests draft review)
- PR author is a bot (e.g., `dependabot`, `renovate`) → report and stop (unless user explicitly requests)

### 2. Analyze Local Changes (Local only)

Apply gate enforcement rules.

### 3. Report Local Findings (Local only)

Present findings using the Local Changes template from `@references/templates.md`.

### 4. Analyze Pull Request (PR only)

1. **Gather PR Context**
   ```bash
   gh pr view <number> --json title,body,author,baseRefName,headRefName,files,additions,deletions,changedFiles
   gh pr diff <number>
   gh pr view <number> --json reviews,comments
   ```
   > **Important:** Run `gh pr diff` exactly as shown — it does not support `-- <file>` path filtering or any additional arguments. Retrieve the full diff once, then analyze relevant sections from the output.

2. Apply gate enforcement rules.

### 5. Report PR Findings (PR only)

Present findings using the Pull Request Review template from `@references/templates.md`.

### 6. Verify

- Note any files or diff hunks that were skipped with rationale

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/feature` | Return to implementation to address review findings |
