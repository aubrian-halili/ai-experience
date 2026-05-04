# Review Response Templates

## Local Changes / Single Files Template

```markdown
## Review Summary

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

### Impact

**Blast Radius**: [Low | Medium | High]

| File | Type | Risk | Key Changes |
|------|------|------|-------------|
| `src/api/users.ts` | Core Logic | Medium | New endpoint |

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

### Testing

[Coverage added/missing — e.g., "Unit tests cover happy path; integration not tested."]

**Verdict**: Approve | Request Changes | Needs Discussion

### Follow-up

1. [Action item]
```
