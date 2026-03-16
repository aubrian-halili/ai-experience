# Jira Ticket Templates

Templates for Bug and Task ticket types with structured fields for clarity and completeness. Templates use Jira wiki markup format so descriptions render correctly in Jira's web interface.

## Bug Template

```jira
h2. Description

[Brief description of the bug]

h2. Steps to Reproduce

# [First step]
# [Second step]
# [Third step]

h2. Expected Behavior

[What should happen]

h2. Actual Behavior

[What actually happens]

h2. Environment

[OS, browser/runtime, app version, relevant config]

h2. Error Messages

{code}
[Error messages, stack traces, or logs]
{code}

h2. Suggested Priority

[Critical/High/Medium/Low] - [Brief justification]
```

## Task Template

```jira
h2. Summary

[Brief description of what needs to be implemented]

h2. Background

[Context and motivation]

h2. Requirements

h3. Functional Requirements

* [Requirement 1]
* [Requirement 2]

h3. Non-Functional Requirements

* [Performance/security/other NFR]

h2. Acceptance Criteria

* [Criterion 1 - specific, measurable]
* [Criterion 2 - specific, measurable]

h2. Technical Details

h3. Approach

[High-level technical approach]

h3. Files to Modify

[List key files and changes]

h3. Dependencies

[Internal or external dependencies]

h2. Testing Requirements

* Unit tests
* Integration tests
* E2E tests (if needed)

h2. Suggested Priority

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
