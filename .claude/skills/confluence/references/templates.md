# Confluence Page Templates

Templates for page creation and update operations, formatted as copy-ready Markdown for paste into the Confluence editor.

## Page Create Template

```markdown
# [Page Title]

## Introduction

[Brief overview — what this page covers and who it is for]

## Background

[Context and motivation — why this page exists, what problem it addresses]

## Content

[Main body — use subsections (##, ###) as needed]

### [Section 1]

[Content]

### [Section 2]

[Content]

## Key Points

- [Key takeaway 1]
- [Key takeaway 2]
- [Key takeaway 3]

## Next Steps

- [ ] [Action item 1]
- [ ] [Action item 2]

## Related Pages

- [Link or reference to related Confluence page]
- [Link or reference to related Jira ticket]
```

## Page Update Template

Use this when updating an existing page. Present both the diff summary and the full updated content.

### Diff Summary Format

```
Changes to: [Page Title]

Added:
  - [New section or content added]

Modified:
  - [Existing section updated — brief description of change]

Removed:
  - [Content removed, if any]
```

### Full Updated Content

Provide the complete updated page in Markdown format (same structure as Page Create Template above), with changes applied.

## Template Selection Guide

| Scenario | Template | Key Sections |
|----------|----------|--------------|
| New documentation page | Page Create | Introduction, Content, Next Steps |
| New feature spec | Page Create | Background, Content (requirements/AC), Next Steps |
| Meeting notes / decision record | Page Create | Background (context), Content (decisions), Next Steps (actions) |
| Updating outdated content | Page Update | Diff Summary + full updated content |
| Adding a new section to existing page | Page Update | Diff Summary (Added) + full updated content |

## Content Guidelines

### Writing for Confluence

**Headings** — Use `#` for page title (H1), `##` for major sections (H2), `###` for subsections (H3). Avoid going deeper than H3.

**Lists** — Use `-` for unordered lists and `1.` for ordered/sequential steps. Use `- [ ]` for action items.

**Code** — Use fenced code blocks with language hints (e.g., ` ```typescript `, ` ```sql `).

**Links** — Use Markdown link syntax: `[Link text](URL)`. For internal Confluence pages, use the full URL: `https://qredab.atlassian.net/wiki/spaces/<SPACE>/pages/<ID>`.

### Sensitive Data

Before generating content, check for and exclude:
- API keys, tokens, secrets
- Passwords or connection strings
- PII (names, emails, personal data beyond what's contextually appropriate)
- Internal infrastructure details that shouldn't be broadly visible
