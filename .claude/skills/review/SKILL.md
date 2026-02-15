---
name: review
description: Use when the user asks to "review this code", "check this PR", "audit this file", "look at my changes", "review this PR", "PR review", requests "code review", mentions "review" in context of code quality, "pull request", "PR #123", or needs code review, PR feedback, or multi-file change analysis.
argument-hint: "[file, PR number, URL, or component to review]"
---

Perform a thorough multi-dimensional review of code, local changes, or pull requests.

## Review Philosophy

- **Precision over completeness** — zero false positives matters more than exhaustive coverage
- **Confidence gate** — internally score each finding 0-100; only report findings with confidence >= 80
- If uncertain about a finding, leave it out rather than risk noise

## Context Detection

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
2. Analyze against review dimensions
3. Report findings with severity levels

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

## Review Dimensions

1. **Correctness** — Does it work? Edge cases handled? Runtime errors possible?
2. **Readability** — Easy to understand? Clear names? Logical structure?
3. **Maintainability** — Easy to modify? Well-organized? Manageable dependencies?
4. **Performance** — Obvious inefficiencies? Resource management? Bottlenecks?
5. **Security** — Input validation? Data protection? Auth correct?
6. **Testing** — Tests present? Coverage adequate? Edge cases tested?
7. **Architecture Alignment** — Follows established patterns? Layer separation correct?
8. **Project Standards Compliance** — Cross-reference against CLAUDE.md conventions

## Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| **Critical** | Security vulnerability, data loss risk, crash | Must fix before merge |
| **High** | Bug, significant perf issue, bad practice | Should fix before merge |
| **Medium** | Code smell, maintainability concern | Fix soon, can merge |
| **Note** | Style, minor improvement, question | Optional |

## Response Format

### For Local Changes / Single Files

```markdown
## Review Summary

**Reviewed**: [File/Component]
**Verdict**: Approve | Request Changes | Needs Discussion

---

### Critical Issues (Must Fix)

1. **[Issue Title]** — `file:line`
   - **Problem**: [Description]
   - **Impact**: [Why this matters]
   - **Fix**:
   ```diff
   - current code
   + suggested code
   ```

### Important Suggestions (Should Fix)

1. **[Title]** — `file:line`
   - **Current**: [What exists]
   - **Suggested**: [What to change]
   - **Reason**: [Why improve]

### Minor Improvements (Could Fix)

1. **[Improvement]** — `file:line` — [Brief suggestion]

### Positive Observations

- [What was done well]
```

### For Pull Requests

```markdown
## Pull Request Review

**PR**: #[number] — [title]
**Author**: @[username]
**Base**: [base-branch] ← [head-branch]
**Files Changed**: [count] | **+[additions]** / **-[deletions]**

---

### Summary

[2-3 sentence summary of what this PR does and why]

### Change Analysis

#### File Breakdown

| File | Type | Risk | Key Changes |
|------|------|------|-------------|
| `src/api/users.ts` | Core Logic | Medium | New endpoint |

#### Impact Assessment

**Blast Radius**: [Low | Medium | High]

- **Direct**: [X files modified]
- **Downstream**: [Y files depend on changes]
- **External**: [Impact on APIs, clients]

### Review Findings

#### Must Address (Blocking)

1. **[Issue]** — `file:line`
   - **Problem**: [Description]
   - **Suggestion**:
   ```diff
   - current
   + suggested
   ```

#### Should Address (Non-blocking)

1. **[Issue]** — `file:line` — [Brief suggestion]

#### Consider (Optional)

- [Improvement idea]

### Testing Analysis

| Test Type | Status | Notes |
|-----------|--------|-------|
| Unit Tests | ✅ Added | Covers happy path |
| Integration | ⚠️ Missing | API integration not tested |
| E2E | N/A | No E2E impact |

### Merge Readiness

| Criterion | Status |
|-----------|--------|
| Tests Passing | ✅ / ❌ |
| No Conflicts | ✅ / ❌ |
| Review Approved | ✅ / ❌ |
| Docs Updated | ✅ / ❌ / N/A |

**Verdict**: ✅ **Ready to Merge** | ⚠️ **Needs Changes** | ❌ **Not Ready**

### Recommended Actions

**Before Merge**:
1. [Action item]

**After Merge**:
1. [Post-merge task]
```

## Specialized Checklists

### API Review Checklist
- [ ] REST conventions followed (proper HTTP methods, status codes)
- [ ] Error responses follow consistent format
- [ ] Authentication/authorization on all sensitive endpoints
- [ ] Rate limiting configured appropriately
- [ ] API versioning strategy clear
- [ ] Request/response validation in place

### Database Review Checklist
- [ ] Schema properly normalized
- [ ] Indexes cover common query patterns
- [ ] N+1 query risks identified
- [ ] Transaction boundaries appropriate
- [ ] Migration strategy documented

### Security Review Checklist
- [ ] Input validation on all external inputs
- [ ] Output encoding to prevent XSS
- [ ] Parameterized queries (no SQL injection)
- [ ] Token handling secure
- [ ] Sensitive data not logged
- [ ] Dependencies checked for vulnerabilities
- [ ] Secrets not hardcoded

## Evaluation Gate

Before finalizing, internally assess:

| Criterion | Status | Notes |
|-----------|--------|-------|
| Critical issues identified? | PASS/FAIL | |
| Security concerns addressed? | PASS/FAIL | |
| Test coverage adequate? | PASS/NEEDS_IMPROVEMENT/FAIL | |
| Performance risks evaluated? | PASS/NEEDS_IMPROVEMENT/FAIL | |
| Architecture alignment verified? | PASS/NEEDS_IMPROVEMENT/FAIL | |

## Error Handling

| Scenario | Response |
|----------|----------|
| PR not found | Check PR number/URL, verify access |
| Cannot fetch diff | Fall back to file-by-file review |
| Too many files | Prioritize by risk, note coverage gaps |
| No test changes | Flag as concern, recommend additions |

## Related Skills

| After This Skill | Consider Using | When |
|-----------------|----------------|------|
| `/review` | `/clean-code` | Deep SOLID analysis needed |
| `/review` | `/architecture` | Structural concerns found |
| `/review` | `/patterns` | Code could benefit from design patterns |
| `/review` | `/security` | Deep security audit needed |
