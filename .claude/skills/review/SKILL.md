---
name: review
description: Comprehensive code and architecture review with severity-rated findings. Use when the user requests code review, PR review, or architecture assessment.
argument-hint: "[file, PR, or component to review]"
---

Perform a thorough multi-dimensional review of the target code or architecture.

## Review Dimensions

1. **Correctness** — Does it work? Edge cases handled? Runtime errors possible?
2. **Readability** — Easy to understand? Clear names? Logical structure?
3. **Maintainability** — Easy to modify? Well-organized? Manageable dependencies?
4. **Performance** — Obvious inefficiencies? Resource management? Bottlenecks?
5. **Security** — Input validation? Data protection? Auth correct?
6. **Testing** — Tests present? Coverage adequate? Edge cases tested?
7. **Architecture Alignment** — Follows established patterns? Layer separation correct? Scalable?

## Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| **Critical** | Security vulnerability, data loss risk, crash | Must fix before merge |
| **High** | Bug, significant perf issue, bad practice | Should fix before merge |
| **Medium** | Code smell, maintainability concern | Fix soon, can merge |
| **Low** | Style, minor improvement | Optional |
| **Info** | Question or observation | No action required |

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

### Questions for Author

- [Clarifying questions about intent or decisions]
```

## Specialized Checklists

**API Review**: REST conventions, error format consistency, auth, rate limiting, versioning, backward compat
**Database Review**: Schema normalization, index coverage, N+1 queries, transactions, connection pooling
**Security Review**: Input validation, output encoding, parameterized queries, token handling, CORS, dependency vulnerabilities
