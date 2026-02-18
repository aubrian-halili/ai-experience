---
name: review
description: Use when the user asks to "review this code", "check this PR", "audit this file", "look at my changes", "review this PR", "PR review", requests "code review", mentions "review" in context of code quality, "pull request", "PR #123", or needs code review, PR feedback, or multi-file change analysis.
argument-hint: "[file, PR number, URL, or component to review]"
allowed-tools: Bash(git *, gh *), Read, Grep, Glob
---

Perform a thorough multi-dimensional review of code, local changes, or pull requests.

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

## Review Philosophy

- **Precision over completeness** — zero false positives matters more than exhaustive coverage
- **Confidence gate** — internally score each finding 0-100; only report findings with confidence >= 80
- If uncertain about a finding, leave it out rather than risk noise

## Context Detection

Use `$ARGUMENTS` if provided (file path, PR number, URL, or component name).

Automatically detect review context based on input:

| Input | Context | Approach |
|-------|---------|----------|
| No argument | Local changes | Check `git diff`, then `git diff --cached` |
| File path | Single file | Direct file review |
| PR number (e.g., `123`, `#123`) | Pull request | Fetch PR via `gh`, multi-file analysis |
| PR URL | Pull request | Extract PR number, fetch via `gh` |
| Branch name | Branch diff | Compare against base branch |

## Process

### For Local Changes / Single Files

1. Read the target code
2. Analyze for correctness, readability, maintainability, performance, security, testing, architecture alignment
3. Cross-reference against CLAUDE.md conventions
4. Report findings with severity levels (see `@references/templates.md` for output structure)

### For Pull Requests

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

5. **Report findings** (see `@references/templates.md` for PR review template)

## Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| **Critical** | Security vulnerability, data loss risk, crash | Must fix before merge |
| **High** | Bug, significant perf issue, bad practice | Should fix before merge |
| **Medium** | Code smell, maintainability concern | Fix soon, can merge |
| **Note** | Style, minor improvement, question | Optional |

## Error Handling

| Scenario | Response |
|----------|----------|
| PR not found | Check PR number/URL, verify access |
| Cannot fetch diff | Fall back to file-by-file review |
| Too many files | Prioritize by risk, note coverage gaps |
| No test changes | Flag as concern, recommend additions |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/clean-code` | Deep SOLID analysis needed |
| `/architecture` | Structural concerns found |
| `/patterns` | Code could benefit from design patterns |
| `/security` | Deep security audit needed |
