---
name: review
description: Use when the user asks to "review this code", "check this PR", "audit this file", "look at my changes", "review this PR", "PR review", requests "code review", mentions "review" in context of code quality, "pull request", "PR #123", or needs code review, PR feedback, or multi-file change analysis.
argument-hint: "[file, PR number, URL, or component to review]"
allowed-tools: Bash(git *, gh *), Read, Grep, Glob
---

Perform a thorough multi-dimensional review of code, local changes, or pull requests.

## Review Philosophy

- **Precision over completeness** — zero false positives matters more than exhaustive coverage
- **Confidence gate** — internally score each finding 0-100; only report findings with confidence >= 80
- **Uncertainty principle** — if uncertain about a finding, leave it out rather than risk noise

## When to Use

### This Skill Is For

- Reviewing local uncommitted changes
- Reviewing specific files or components
- Analyzing pull requests with multi-file changes
- Providing structured code review feedback
- Assessing merge readiness

### Use a Different Approach When

- Deep SOLID analysis needed → use `/clean-code`
- Architectural concerns found → use `/architecture`
- Design pattern improvements → use `/patterns`
- Security audit needed → use `/security`

## Input Classification

Classify `$ARGUMENTS` to determine the review workflow:

| Type | Indicators | Approach |
|------|-----------|----------|
| **Uncommitted Changes** | No argument | Diff-based local review (steps 1–3) |
| **Single File** | File path | Direct file review (steps 1–3) |
| **Branch Diff** | Branch name | Branch comparison review (steps 1–3) |
| **Pull Request** | PR number (`123`, `#123`) or PR URL | Full PR review (steps 1, 4–5) |

## Process

**Branch point:** Local review → steps 1–3. PR review → steps 1, 4–5.

### 1. Pre-flight

- Classify review context from `$ARGUMENTS` using the Input Classification table
- Verify working directory is a git repo: `git rev-parse --is-inside-work-tree`
- For local reviews: confirm changes exist via `git diff` and `git diff --cached`
- For PR reviews: verify `gh` is authenticated: `gh auth status`
- Check for CLAUDE.md conventions to cross-reference during review

**Stop conditions:**
- Not a git repository → report and stop
- No local changes found (for local review) → report and suggest specifying a file or PR number
- PR review requested but `gh` not authenticated → provide `gh auth login` instructions and stop
- Ambiguous argument (could be file path or component name) → search codebase, prefer exact file match

### 2. Analyze Local Changes (Local only)

1. Read target code (diff output for uncommitted changes, full file for single-file review)
2. Analyze across dimensions: correctness, readability, maintainability, performance, security, testing, architecture alignment
3. Cross-reference against CLAUDE.md conventions
4. Apply confidence gate — only flag findings scored >= 80

### 3. Report Local Findings (Local only)

Present findings using severity levels and the Local Changes template from `@references/templates.md`.

**No findings case:** If analysis produces no findings above the confidence threshold, explicitly state: "No findings above confidence threshold. Code meets review standards for the dimensions analyzed."

### 4. Analyze Pull Request (PR only)

1. **Gather PR Context**
   ```bash
   gh pr view <number> --json title,body,author,baseRefName,headRefName,files,additions,deletions,changedFiles
   gh pr diff <number>
   gh pr view <number> --json reviews,comments
   ```

2. **Classify Changes**
   | Category | Indicators | Review Focus |
   |----------|-----------|--------------|
   | **Core Logic** | Business rules, algorithms | Correctness, edge cases |
   | **API Changes** | Endpoints, contracts | Breaking changes, versioning |
   | **Data Layer** | Models, migrations, queries | Data integrity, performance |
   | **Configuration** | Config files, env vars | Security, deployment impact |
   | **Tests** | Test files | Coverage, quality |
   | **Documentation** | README, comments | Accuracy, completeness |
   | **Dependencies** | package.json, lock files | Security, compatibility |

3. **Assess Impact**
   - **Direct Impact**: Files modified
   - **Downstream Impact**: Files that depend on changes
   - **Upstream Impact**: Changes to dependencies

4. **Evaluate Risk**
   | Risk Factor | Low | Medium | High |
   |-------------|-----|--------|------|
   | Files Changed | 1-5 | 6-15 | 16+ |
   | Lines Changed | <100 | 100-500 | 500+ |
   | Test Coverage | Added/Updated | Unchanged | Removed |
   | Breaking Changes | None | Internal only | External API |

### 5. Report PR Findings (PR only)

Present findings using the Pull Request Review template from `@references/templates.md`.

Apply confidence gate — only flag findings scored >= 80.

## Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| **Critical** | Security vulnerability, data loss risk, crash | Must fix before merge |
| **High** | Bug, significant perf issue, bad practice | Should fix before merge |
| **Medium** | Code smell, maintainability concern | Fix soon, can merge |
| **Note** | Style, minor improvement, question | Optional |

## Output Principles

- **Severity-first ordering** — group findings by severity (Critical first), not by file or dimension
- **Location precision** — every finding references `file:line`; for PR reviews include diff hunk context
- **Actionable fixes** — provide concrete fix suggestions with diff examples for Critical and High findings
- **Balanced perspective** — include positive observations; a review that only lists problems discourages contributors

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Review local uncommitted changes (`git diff` + `git diff --cached`) |
| File path (e.g., `src/auth/login.ts`) | Review the specific file |
| PR number (e.g., `123`, `#123`) | Full pull request review via `gh` |
| PR URL (e.g., `github.com/.../pull/123`) | Extract PR number, full pull request review |
| Branch name (e.g., `feature/auth`) | Review branch diff against base branch |
| Component name (e.g., `AuthService`) | Locate component files, review matching files |

## Error Handling

| Scenario | Response |
|----------|----------|
| Not a git repository | Report and stop |
| No local changes found | Report; suggest specifying a file or PR number |
| File not found | Report the missing path and ask user to verify |
| PR not found | Check PR number/URL format, verify repository access with `gh` |
| `gh` not authenticated | Report auth status, provide `gh auth login` instructions |
| Branch not found | List available branches, ask user to verify |
| Cannot fetch diff | Fall back to file-by-file review using `gh pr view --json files` |
| Too many files (>30 changed) | Prioritize by risk using Evaluate Risk table, note coverage gaps |

Never silently omit findings or skip review dimensions—surface limitations and partial coverage explicitly.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/clean-code` | Deep SOLID analysis needed |
| `/architecture` | Structural concerns found |
| `/patterns` | Code could benefit from design patterns |
| `/security` | Deep security audit needed |
| `/explore` | Understand codebase context before reviewing unfamiliar code |
