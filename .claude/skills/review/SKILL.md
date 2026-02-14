---
name: review
description: Use when the user asks to "review this code", "check this PR", "audit this file", "look at my changes", requests "code review", mentions "review" in context of code quality, or needs PR feedback.
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

## Evaluation Gate

Before finalizing the review, internally assess each criterion:

| Criterion | Status | Notes |
|-----------|--------|-------|
| Critical issues identified and actionable? | PASS/FAIL | |
| Security concerns addressed? | PASS/FAIL | |
| Test coverage adequate? | PASS/NEEDS_IMPROVEMENT/FAIL | |
| Performance risks evaluated? | PASS/NEEDS_IMPROVEMENT/FAIL | |
| Architecture alignment verified? | PASS/NEEDS_IMPROVEMENT/FAIL | |

**Overall**: PASS | NEEDS_IMPROVEMENT | FAIL

- If **FAIL** on any criterion → must provide actionable feedback for each failing item
- If **NEEDS_IMPROVEMENT** → include specific suggestions in Minor Improvements section
- Only **PASS** overall when no Critical/High issues remain

## Iteration Protocol

For complex reviews, support iterative refinement:

1. **Initial Pass**: Identify all potential findings
2. **Self-Evaluation**: Score each finding against confidence threshold (>= 80)
3. **Refinement**: Re-analyze low-confidence findings with additional context if available
4. **Final Report**: Present only validated findings

If user requests deeper analysis, explicitly re-run with expanded scope or lower confidence threshold.

## Error Handling

When analysis is incomplete or uncertain:

1. **Partial Results**: Present what was found with clear `[Incomplete]` markers
2. **Confidence Flags**: Mark sections as `[High Confidence]` or `[Needs Verification]`
3. **Fallback Strategy**: If primary approach fails (e.g., can't access file), suggest alternative investigation paths
4. **Scope Limitations**: Explicitly state what was NOT reviewed and why

Never silently omit findings—surface limitations explicitly.

## Specialized Checklists

### API Review Checklist
- [ ] REST conventions followed (proper HTTP methods, status codes)
- [ ] Error responses follow consistent format (RFC 7807 or project standard)
- [ ] Authentication/authorization on all sensitive endpoints
- [ ] Rate limiting configured appropriately
- [ ] API versioning strategy clear and consistent
- [ ] Backward compatibility considered for changes
- [ ] Request/response validation in place
- [ ] CORS configuration appropriate

### Database Review Checklist
- [ ] Schema properly normalized (or denormalized with justification)
- [ ] Indexes cover common query patterns
- [ ] N+1 query risks identified and mitigated
- [ ] Transaction boundaries appropriate
- [ ] Connection pooling configured
- [ ] Migration strategy documented
- [ ] Soft delete vs hard delete strategy clear
- [ ] Data retention policy considered

### Security Review Checklist
- [ ] Input validation on all external inputs
- [ ] Output encoding to prevent XSS
- [ ] Parameterized queries (no SQL injection)
- [ ] Token handling secure (storage, transmission, expiry)
- [ ] Sensitive data not logged
- [ ] Dependencies checked for known vulnerabilities
- [ ] Secrets not hardcoded
- [ ] Authentication state validated server-side

---

## Related Skills

| After This Skill | Consider Using | When |
|-----------------|----------------|------|
| `/review` | `/clean-code` | Deep SOLID analysis needed |
| `/review` | `/architecture` | Structural concerns or design issues found |
| `/review` | `/patterns` | Code structure could benefit from design patterns |
| `/review` | `/adr` | Significant decision should be documented |

> For deep code quality and SOLID analysis, use `/clean-code` after addressing critical issues.
