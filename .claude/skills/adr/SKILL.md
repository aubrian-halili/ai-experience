---
name: adr
description: Create Architecture Decision Records for documenting significant technical decisions.
argument-hint: "[decision title]"
disable-model-invocation: true
---

Create an Architecture Decision Record using the template in @template.md.

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

## Process

1. Ask the user for the decision context if not provided via `$ARGUMENTS`
2. Identify the decision drivers (what forces are at play?)
3. List 2-3 considered options with Pros/Cons
4. Recommend a decision with clear rationale
5. Document consequences (positive, negative, risks)
6. Write the ADR to `docs/architecture/decisions/adr-NNN-title.md`

## Statuses

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
