# Jira Ticket Templates

Templates for Bug and Task ticket types with structured fields for clarity and completeness.

## Bug Template

```markdown
## Description

[Brief description of the bug - what is happening]

## Steps to Reproduce

1. [First step]
2. [Second step]
3. [Third step]

## Expected Behavior

[What should happen]

## Actual Behavior

[What actually happens]

## Environment

| Property | Value |
|----------|-------|
| OS | [e.g., macOS 14.0, Windows 11, Ubuntu 22.04] |
| Browser | [e.g., Chrome 120, Safari 17] |
| App Version | [e.g., v2.1.0, commit abc123] |
| Node Version | [if applicable] |
| Other | [any other relevant environment info] |

## Severity Assessment

| Aspect | Assessment |
|--------|------------|
| Impact | [High/Medium/Low - how many users affected] |
| Frequency | [Always/Sometimes/Rarely] |
| Workaround | [Yes/No - is there a workaround available] |

## Additional Context

### Error Messages

```
[Paste any error messages, stack traces, or logs here]
```

### Screenshots/Recordings

[Attach or describe any visual evidence]

### Related Information

- Related tickets: [PROJ-XXX]
- Related code: [file paths or links]
- First noticed: [date or version]

## Git Context

- **Ticket ID**: `[extracted from branch, e.g., UN-1234]`
- **Branch**: `[branch-name, e.g., UN-1234-fix-crash]`
- **Recent commits**:
  - [commit summary 1]
  - [commit summary 2]

## Suggested Priority

[Critical/High/Medium/Low] - [Brief justification]
```

## Task Template

```markdown
## Summary

[Brief description of what needs to be implemented]

## Background

[Context and motivation for this task]

## Requirements

### Functional Requirements

- [ ] [Requirement 1]
- [ ] [Requirement 2]
- [ ] [Requirement 3]

### Non-Functional Requirements

- [ ] [Performance requirement]
- [ ] [Security requirement]
- [ ] [Other NFR]

## Acceptance Criteria

- [ ] [Criterion 1 - specific, measurable]
- [ ] [Criterion 2 - specific, measurable]
- [ ] [Criterion 3 - specific, measurable]

## Technical Details

### Approach

[High-level technical approach]

### Files to Modify

| File | Change |
|------|--------|
| `path/to/file.ts` | [Description of change] |

### Files to Create

| File | Purpose |
|------|---------|
| `path/to/new/file.ts` | [Purpose] |

### Dependencies

- [ ] [Dependency 1 - internal or external]
- [ ] [Dependency 2]

### API Changes

[If applicable, describe API changes]

```typescript
// New endpoint or interface
interface NewFeature {
  // ...
}
```

## Testing Requirements

- [ ] Unit tests for [component]
- [ ] Integration tests for [flow]
- [ ] E2E tests for [scenario]

## Documentation

- [ ] Update README
- [ ] Update API docs
- [ ] Add inline code comments

## Git Context

- **Ticket ID**: `[extracted from branch, e.g., UN-1234]`
- **Branch**: `[branch-name, e.g., UN-1234-implement-feature]`
- **Recent commits**:
  - [commit summary 1]
  - [commit summary 2]
- **Files changed**: [count] files

## Suggested Priority

[High/Medium/Low] - [Brief justification]

## Estimated Scope

[S/M/L/XL] - [Brief justification]
```

## Template Selection Guide

| Scenario | Template | Key Sections |
|----------|----------|--------------|
| Something isn't working | Bug | Steps to Reproduce, Expected vs Actual |
| Error/crash reported | Bug | Error Messages, Environment |
| New functionality needed | Task | Requirements, Acceptance Criteria |
| Code improvement | Task | Technical Details, Testing |
| Configuration change | Task | Requirements (simple), Files to Modify |

## Field Completion Guidelines

### For Bugs

**Steps to Reproduce** - Be specific:
- Bad: "Click the button"
- Good: "Click the 'Submit' button in the top-right corner of the form"

**Expected vs Actual** - Be precise:
- Bad: "It should work"
- Good: "Form should submit and redirect to /dashboard with success message"

**Environment** - Include versions:
- Always include OS, browser/runtime versions
- Include app version or commit hash
- Note any special configuration

### For Tasks

**Acceptance Criteria** - Make them testable:
- Bad: "User can log in"
- Good: "User can log in with email/password and receives JWT token valid for 24 hours"

**Technical Details** - Be actionable:
- List specific files to modify
- Note any architectural decisions
- Call out potential risks

**Scope Estimation**:
- **S**: < 1 day, single file, no dependencies
- **M**: 1-3 days, few files, minimal dependencies
- **L**: 3-5 days, multiple files/components, some dependencies
- **XL**: > 5 days, significant changes, many dependencies

## Auto-Population from Git Context

When git context is available, auto-populate:

### From Branch Name

| Branch Pattern | Extraction |
|---------------|------------|
| `UN-1234-add-user-auth` | Ticket: UN-1234, Title: "Add user auth" |
| `UN-5678-fix-login-redirect` | Ticket: UN-5678, Type: Bug, Title: "Fix login redirect" |
| `PROJ-123-implement-caching` | Ticket: PROJ-123, Title: "Implement caching" |
| `UN-9012-refactor-auth-flow` | Ticket: UN-9012, Title: "Refactor auth flow" |

### From Commits

| Commit Pattern | Extraction |
|---------------|------------|
| `UN-1234 feat: add login endpoint` | Ticket: UN-1234, Title basis, Type: Task |
| `UN-1234 fix: resolve null pointer` | Ticket: UN-1234, Title basis, Type: Bug |
| `Closes #123` or `Fixes #123` | Related GitHub issue reference |
| `PROJ-456` prefix in message | Related Jira ticket reference |

### From Diff

| Change Pattern | Inference |
|---------------|-----------|
| New test files added | Include in Testing section |
| Config files changed | Note in Environment/Technical Details |
| Error handling added | May indicate bug fix context |
