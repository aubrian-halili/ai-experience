# ADR Guidelines

Guidance for when and how to create Architecture Decision Records.

## When to Write an ADR

**Write one when:**
- Choosing between multiple valid technical approaches
- Adopting or changing frameworks/libraries
- Defining API contracts or data formats
- Establishing coding standards or patterns
- Making infrastructure decisions
- Changing system architecture

**Skip when:**
- Trivial decisions easily reversed
- Standard practices with no alternatives
- Bug fixes or routine maintenance

## ADR Statuses

| Status | Meaning |
|--------|---------|
| **Proposed** | Under discussion, not yet accepted |
| **Accepted** | Decision made and in effect |
| **Deprecated** | No longer applies, kept for history |
| **Superseded** | Replaced by a newer ADR |

## File Organization

```text
docs/architecture/decisions/
├── README.md
├── adr-001-use-typescript.md
├── adr-002-api-versioning-strategy.md
└── adr-003-database-selection.md
```
