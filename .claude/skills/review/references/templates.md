# Review Response Templates

## Local Changes / Single Files Template

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

## Pull Request Review Template

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
