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
| "I know the line number from the diff" | Diff offsets are not source file line numbers; always read the source file |
| "The confidence gate is too strict — I'll report it anyway" | The gate exists to protect signal-to-noise ratio; below 80 means insufficient evidence |
| "Skipping the specialized passes, the diff is small" | The threshold is >10 files for parallel agents, not for skipping passes entirely |

### Confidence Scoring Rubric

| Score | Meaning | Action |
|-------|---------|--------|
| **0** | False positive or pre-existing issue not introduced by this change | Do not report |
| **25** | Possible issue but unverified — would need more context or domain knowledge | Do not report |
| **50** | Real issue but minor impact — unlikely to cause problems in practice | Do not report |
| **75** | Important and verified — real issue with meaningful impact | Do not report (below gate) |
| **80** | Verified with strong supporting evidence — real issue, confirmed impact | Report |
| **100** | Definite and self-evident — clearly wrong, clearly harmful | Report |

**Gate enforcement — a finding reaches 80 only when ALL of these are true:**
1. You can cite the exact `file:line` where the issue occurs (read the source file, not just the diff)
2. You ran `git blame -L <start>,<end> <file>` to confirm this is a new issue, not pre-existing
3. You can describe the concrete negative consequence if the issue is left unfixed

If any of these are missing, score the finding below 80 regardless of how "obvious" it seems.

### Do Not Flag

These categories produce noise, not value — exclude them regardless of confidence:

1. **Linter/formatter issues** — these are caught by automated tooling, not human review
2. **Compiler/build errors** — the CI pipeline catches these; flagging them wastes review time
3. **Pedantic style nitpicks** — minor formatting preferences not codified in project conventions
4. **Out-of-scope missing features** — functionality the PR never intended to add
5. **TODOs the author already flagged** — the author is aware; re-flagging is redundant

## Input Handling

Pass `--refactor` to perform a Clean Code & SOLID-focused review with Edit suggestions (e.g., `src/auth/ --refactor`). All other inputs (file paths, PR numbers, branch names, component names) are inferred from context.

## Specialized Review Passes

When the review scope is large (>10 files) or the user requests a thorough review, dispatch targeted subagents: `code-quality-reviewer` for quality dimensions (Type Safety, Type Design, Error Handling, Test Coverage, Performance, Clean Code, Documentation) and `security-scanner` for the security pass. See agent definitions for dimension details.

## Process

**Branch point:** Local review → steps 1–3, 6. PR review → steps 1, 4–6.

### 1. Pre-flight

- For PR reviews: verify `gh` is authenticated: `gh auth status`
- For PR reviews: screen PR eligibility before proceeding:
  ```bash
  gh pr view <number> --json state,isDraft,author,labels
  ```

**Stop conditions:**
- Not a git repository → report and stop
- No local changes found (for local review) → report and suggest specifying a file or PR number
- PR review requested but `gh` not authenticated → provide `gh auth login` instructions and stop
- PR is closed or merged → report state and stop
- PR is a draft → report draft status and stop (unless user explicitly requests draft review)
- PR author is a bot (e.g., `dependabot`, `renovate`) → report and stop (unless user explicitly requests)
- Ambiguous argument (could be file path or component name) → search codebase, prefer exact file match

### 2. Analyze Local Changes (Local only)

1. Read target code (diff output for uncommitted changes, full file for single-file review)
2. Apply gate enforcement rules (file:line from source, git blame to confirm newness, concrete consequence)

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
   >
   > **Line number rule:** Diff hunk headers (e.g., `@@ -10,5 +12,7 @@`) show relative offsets, not source file line numbers. Never cite these as `file:line` references. Use `Read` on the actual source file to confirm the correct line number before citing it in any finding.

2. Apply gate enforcement rules (file:line from source, git blame to confirm newness, concrete consequence)

### 5. Report PR Findings (PR only)

Before reporting, re-check PR state to avoid posting stale reviews:
```bash
gh pr view <number> --json state,isDraft,updatedAt,commits
```
- If PR is now closed or merged → skip reporting, inform user
- If new commits were pushed since analysis began → warn user that findings may be outdated and offer to re-run

Present findings using the Pull Request Review template from `@references/templates.md`.

### 6. Verify

- Confirm all files or diff hunks in scope were evaluated; note any that were skipped with rationale
- Sanity-check severity distribution — if all findings are Critical or all are Note, re-evaluate consistency

## Code Smells to Detect (Clean Code Pass)

Project-specific preferences (beyond standard smells):

| Smell | Refactoring |
|-------|-------------|
| Nested Ternaries | `if`/`else` chains or `switch` statements |
| Dense One-liners | Break into named steps for readability |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/receiving-review` | Addressing feedback received on your PR |
| `/verify` | Verify completeness against a plan, not code quality |
| `/feature` | Return to implementation to address review findings |
