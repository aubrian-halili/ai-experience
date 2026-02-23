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

## ADR Numbering

**Determining the next number:**
1. List existing ADRs: `ls docs/architecture/decisions/adr-*.md`
2. Find the highest number (e.g., `adr-003`)
3. Increment by 1 (e.g., `adr-004`)
4. If no ADRs exist, start at `adr-001`

**Naming convention:**
- Format: `adr-NNN-kebab-case-title.md`
- Number: Zero-padded 3 digits (`001`, `002`, etc.)
- Title: Lowercase, hyphens between words, descriptive
- Examples:
  - `adr-001-use-typescript.md`
  - `adr-015-api-gateway-pattern.md`
  - `adr-042-event-sourcing-for-orders.md`

## Superseding ADRs

**When to supersede vs amend:**
- **Supersede** when the core decision changes (new ADR replaces old one)
- **Amend** when adding context or updating status (edit existing ADR)

**How to supersede:**
1. Create new ADR with incremented number
2. Set new ADR status to `Accepted`
3. Update old ADR:
   - Change status to `Superseded by ADR-NNN`
   - Link to the new ADR in a footer note
4. Cross-link both ADRs in their "Related Decisions" sections

**Example superseding workflow:**
- `adr-003-monolithic-deployment.md` → status becomes `Superseded by ADR-012`
- `adr-012-microservices-migration.md` → references `Supersedes ADR-003`
