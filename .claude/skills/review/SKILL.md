---
name: review
description: Comprehensive code and architecture review with severity-rated findings. Use when the user requests code review, PR review, or architecture assessment.
argument-hint: "[file, PR, or component to review]"
---

Perform a thorough multi-dimensional review of the target code or architecture.

## Review Philosophy

- **Precision over completeness** — zero false positives matters more than exhaustive coverage
- **Confidence gate** — internally score each finding 0-100; only report findings with confidence >= 80
- If uncertain about a finding, leave it out rather than risk noise

## Default Scope

When no argument is provided:
1. Check `git diff` (unstaged changes)
2. If empty, check `git diff --cached` (staged changes)
3. If both empty, ask the user what to review

When an explicit file, PR, or component argument is provided, review that target directly.

## Review Dimensions

1. **Correctness** — Does it work? Edge cases handled? Runtime errors possible?
2. **Readability** — Easy to understand? Clear names? Logical structure?
3. **Maintainability** — Easy to modify? Well-organized? Manageable dependencies?
4. **Performance** — Obvious inefficiencies? Resource management? Bottlenecks?
5. **Security** — Input validation? Data protection? Auth correct?
6. **Testing** — Tests present? Coverage adequate? Edge cases tested?
7. **Architecture Alignment** — Follows established patterns? Layer separation correct? Scalable?
8. **Project Standards Compliance** — Cross-reference findings against CLAUDE.md conventions:
   - Layer boundary violations (domain must not import infrastructure or presentation)
   - SOLID enforcement (SRP and DIP specifically)
   - Strict typing and input validation
   - Testing pyramid adherence (unit > integration > e2e)

## Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| **Critical** | Security vulnerability, data loss risk, crash | Must fix before merge |
| **High** | Bug, significant perf issue, bad practice | Should fix before merge |
| **Medium** | Code smell, maintainability concern | Fix soon, can merge |
| **Note** | Style, minor improvement, question, or observation | Optional |

## Response Format

```markdown
## Review Summary

**Reviewed**: [File/Component/PR]
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

## Specialized Checklists

**API Review**: REST conventions, error format consistency, auth, rate limiting, versioning, backward compat
**Database Review**: Schema normalization, index coverage, N+1 queries, transactions, connection pooling
**Security Review**: Input validation, output encoding, parameterized queries, token handling, CORS, dependency vulnerabilities

---

> For deep code quality and SOLID analysis, use `/clean-code` after addressing critical issues.
