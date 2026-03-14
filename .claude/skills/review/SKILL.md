---
name: review
description: >-
  User asks for "code review", "review this PR", "review my changes",
  "review PR #123", or "is this ready to merge".
  Not for: deep refactoring (use /clean-code), security audit (use /security),
  verifying completeness against a plan (use /verify).
argument-hint: "[file, PR number, URL, or component to review]"
allowed-tools: Bash(git *, gh *), Read, Grep, Glob, Agent
---

**Current branch:** !`git branch --show-current`
**Diff stats:** !`git diff --stat origin/main..HEAD 2>/dev/null || git diff --stat HEAD~1..HEAD`

Perform a thorough multi-dimensional review of code, local changes, or pull requests.

## Review Philosophy

- **Precision over completeness** — zero false positives matters more than exhaustive coverage
- **Confidence gate** — internally score each finding 0-100; only report findings with confidence >= 80
- **Uncertainty principle** — if uncertain about a finding, leave it out rather than risk noise
- **Context-aware** — respect existing patterns and conventions; cross-reference CLAUDE.md before flagging style issues
- **Constructive balance** — pair criticism with positive observations; reviews that only list problems discourage contributors

### Confidence Scoring Rubric

| Score | Meaning | Action |
|-------|---------|--------|
| **0** | False positive or pre-existing issue not introduced by this change | Do not report |
| **25** | Possible issue but unverified — would need more context or domain knowledge | Do not report |
| **50** | Real issue but minor impact — unlikely to cause problems in practice | Do not report |
| **75** | Important and verified — real issue with meaningful impact | Do not report (below gate) |
| **100** | Definite and self-evident — clearly wrong, clearly harmful | Report |

The confidence gate remains **>= 80**. In practice, only findings you are highly confident about (75+ verified with strong supporting evidence pushing to 80+, or 100-level obvious issues) should be reported.

### Do Not Flag

These categories produce noise, not value — exclude them regardless of confidence:

1. **Linter/formatter issues** — these are caught by automated tooling, not human review
2. **Compiler/build errors** — the CI pipeline catches these; flagging them wastes review time
3. **Pre-existing issues** — problems that existed before the current change (verify with `git blame`)
4. **Pedantic style nitpicks** — minor formatting preferences not codified in project conventions
5. **Out-of-scope missing features** — functionality the PR never intended to add
6. **TODOs the author already flagged** — the author is aware; re-flagging is redundant

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

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Review uncommitted changes | Diff-based local review |
| File path (e.g., `src/auth/login.ts`) | Review specific file | Direct file analysis |
| Component name (e.g., `AuthService`) | Review matching files | Locate component, review matches |
| Branch name (e.g., `feature/auth`) | Review branch changes | Branch diff against base |
| PR number/URL (e.g., `123`, `#123`, URL) | Review pull request | Full PR analysis via `gh` |

## Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| **Critical** | Security vulnerability, data loss risk, crash | Must fix before merge |
| **High** | Bug, significant perf issue, bad practice | Should fix before merge |
| **Medium** | Code smell, maintainability concern | Fix soon, can merge |
| **Note** | Style, minor improvement, question | Optional |

## Specialized Review Passes

When the review scope is large (>10 files) or the user requests a thorough review, run targeted passes using subagents. Use `code-quality-reviewer` agents (from `.claude/agents/code-quality-reviewer.md`) for quality dimensions and `security-scanner` (from `.claude/agents/security-scanner.md`) for the security pass:

| Pass | Agent | Focus | Key Questions |
|------|-------|-------|---------------|
| **Type Safety** | `code-quality-reviewer` | Type correctness, generic usage, any casts | Are types precise? Any `any` escape hatches? |
| **Error Handling** | `code-quality-reviewer` | Error paths, missing catches, error propagation | Are all failure modes handled? Errors informative? |
| **Test Coverage** | `code-quality-reviewer` | Test quality, missing scenarios, assertion depth | Are edge cases tested? Are assertions meaningful? |
| **Performance** | `code-quality-reviewer` | N+1 queries, unnecessary re-renders, memory leaks | Any hot paths? Algorithmic complexity concerns? |
| **Security** | `security-scanner` | Input validation, auth checks, data exposure | Defer deep findings to `/security` |

Each pass produces findings with:
- **Confidence score** (0-100): Only surface findings >= 80
- **Severity**: Using existing severity levels (Critical/High/Medium/Note)
- **Pass tag**: e.g., `[Type Safety]` prefix so findings are traceable to the pass

## Process

**Branch point:** Local review → steps 1–3, 6. PR review → steps 1, 4–6.

### 1. Pre-flight

- Classify review context from `$ARGUMENTS` using the Input Classification table
- Verify working directory is a git repo: `git rev-parse --is-inside-work-tree`
- For local reviews: confirm changes exist via `git diff` and `git diff --cached`
- For PR reviews: verify `gh` is authenticated: `gh auth status`
- For PR reviews: screen PR eligibility before proceeding:
  ```bash
  gh pr view <number> --json state,isDraft,author,labels
  ```
- Check for CLAUDE.md conventions to cross-reference during review

**Stop conditions:**
- Not a git repository → report and stop
- No local changes found (for local review) → report and suggest specifying a file or PR number
- PR review requested but `gh` not authenticated → provide `gh auth login` instructions and stop
- PR is closed or merged → report state and stop
- PR is a draft → report draft status and stop (unless user explicitly requests draft review)
- PR author is a bot (e.g., `dependabot`, `renovate`) → report and stop (unless user explicitly requests)
- Ambiguous argument (could be file path or component name) → search codebase, prefer exact file match

### 1.5. Extract Intent

Before analyzing code quality, establish what the code is supposed to do:

- **For PR reviews:** Read the PR description and any linked Jira ticket to understand the intended behavior
- **For file reviews:** Ask what the code was supposed to accomplish if not obvious from context
- **For local changes:** Infer intent from commit messages, branch name, and diff context

This enables two-stage analysis:
- **Stage 1 — Spec Compliance:** Does the code implement the stated intent? Flag gaps between what was requested and what was built. If Stage 1 fails, report spec compliance issues before proceeding.
- **Stage 2 — Code Quality:** Is the code well-written? Only perform quality review after confirming the code addresses the right problem.

### 2. Analyze Local Changes (Local only)

1. Read target code (diff output for uncommitted changes, full file for single-file review)
2. Analyze across dimensions: correctness, readability, maintainability, performance, security, testing, architecture alignment
3. For any potential finding, run `git blame -L <start>,<end> <file>` to confirm the issue was introduced in the current change. Score pre-existing issues as 0.
4. Cross-reference against CLAUDE.md conventions
5. Apply confidence gate — only flag findings scored >= 80

### 2.5. Specialized Review Passes (Optional Deep Dive)

When scope is large (>10 files) or user requests thorough review, run the Specialized Review Passes defined above.

### 3. Report Local Findings (Local only)

Present findings using the Severity Levels defined above and the Local Changes template from `@references/templates.md`.

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

4. For any potential finding, run `git blame -L <start>,<end> <file>` to confirm the issue was introduced in the current change. Score pre-existing issues as 0.

5. **Evaluate Risk**
   | Risk Factor | Low | Medium | High |
   |-------------|-----|--------|------|
   | Files Changed | 1-5 | 6-15 | 16+ |
   | Lines Changed | <100 | 100-500 | 500+ |
   | Test Coverage | Added/Updated | Unchanged | Removed |
   | Breaking Changes | None | Internal only | External API |

### 4.5. Specialized Review Passes (Optional Deep Dive)

When PR has >10 changed files or user requests thorough review, run the Specialized Review Passes defined above.

### 5. Report PR Findings (PR only)

Before reporting, re-check PR state to avoid posting stale reviews:
```bash
gh pr view <number> --json state,isDraft,updatedAt,commits
```
- If PR is now closed or merged → skip reporting, inform user
- If new commits were pushed since analysis began → warn user that findings may be outdated and offer to re-run

Present findings using the Pull Request Review template from `@references/templates.md`.

Apply confidence gate — only flag findings scored >= 80.

### 6. Verify

- Confirm all files or diff hunks in scope were evaluated; note any that were skipped with rationale
- Verify every reported finding includes a `file:line` reference and a severity from the Severity Levels table
- Sanity-check severity distribution — if all findings are Critical or all are Note, re-evaluate consistency
- Suggest next steps: recommend related skills for deeper analysis, or state merge readiness for PR reviews

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
| Component name (e.g., `AuthService`) | Locate component files, review matching files |
| Branch name (e.g., `feature/auth`) | Review branch diff against base branch |
| PR number/URL (e.g., `123`, `#123`, or PR URL) | Full pull request review via `gh` |

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
| `/receiving-review` | Addressing feedback received on your PR |
| `/clean-code` | Deep SOLID analysis needed |
| `/architecture` | Structural concerns found |
| `/patterns` | Code could benefit from design patterns |
| `/security` | Deep security audit needed |
| `/explore` | Understand codebase context before reviewing unfamiliar code |
| `/config-management` | Audit project configuration and CLAUDE.md consistency |
