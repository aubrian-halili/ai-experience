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

- [Requirement 1]
- [Requirement 2]

### Non-Functional Requirements

- [Performance/security/other NFR]

## Acceptance Criteria

- [Criterion 1 - specific, measurable]
- [Criterion 2 - specific, measurable]

## Technical Details

### Approach

[High-level technical approach]

### Files to Modify

[List key files and changes]

### Dependencies

[Internal or external dependencies]

## Testing Requirements

- Unit tests
- Integration tests
- E2E tests (if needed)

## Suggested Priority

[Critical/High/Medium/Low] - [Brief justification]
```

## Template Selection Guide

| Scenario | Template | Key Sections |
|----------|----------|--------------|
| Something isn't working | Bug | Steps to Reproduce, Expected vs Actual |
| Error/crash reported | Bug | Error Messages, Environment |
| New functionality needed | Task | Requirements, Acceptance Criteria |
| Code improvement | Task | Technical Details, Testing |
| Configuration change | Task | Requirements (simple), Files to Modify |
