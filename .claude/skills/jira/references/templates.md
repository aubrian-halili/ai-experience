# Jira Ticket Templates

Templates for Bug and Task ticket types with structured fields for clarity and completeness.

## Bug Template

```markdown
## Description

[Brief description of the bug]

## Steps to Reproduce

1. [First step]
2. [Second step]
3. [Third step]

## Expected Behavior

[What should happen]

## Actual Behavior

[What actually happens]

## Environment

[OS, browser/runtime, app version, relevant config]

## Error Messages

```
[Error messages, stack traces, or logs]
```

## Suggested Priority

[Critical/High/Medium/Low] - [Brief justification]
```

## Task Template

```markdown
## Summary

[Brief description of what needs to be implemented]

## Background

[Context and motivation]

## Requirements

### Functional Requirements

- [ ] [Requirement 1]
- [ ] [Requirement 2]

### Non-Functional Requirements

- [ ] [Performance/security/other NFR]

## Acceptance Criteria

- [ ] [Criterion 1 - specific, measurable]
- [ ] [Criterion 2 - specific, measurable]

## Technical Details

### Approach

[High-level technical approach]

### Files to Modify

[List key files and changes]

### Dependencies

[Internal or external dependencies]

## Testing Requirements

- [ ] Unit tests
- [ ] Integration tests
- [ ] E2E tests (if needed)

## Suggested Priority

[High/Medium/Low] - [Brief justification]
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

**From branch name**: Extract ticket ID and title from pattern `PROJ-123-description`

**From commits**:
- `fix:` prefix → Bug type
- `feat:` prefix → Task type
- `Closes #123` → Related issue reference

**From diff**:
- New tests → Testing section
- Config changes → Environment/Technical Details
- Error handling → Bug fix context
