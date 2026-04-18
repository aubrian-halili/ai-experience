# Architecture

## ADR Conventions

- Store ADRs in `docs/architecture/decisions/adr-NNN-kebab-case-title.md`
- Number format: zero-padded 3 digits (`adr-001`, `adr-002`, etc.)
- **Always show the complete ADR to the user for review before writing to disk**

## ADR Template

```markdown
# ADR-[NNN]: [Decision Title]

**Status:** Proposed | Accepted | Deprecated | Superseded
**Date:** YYYY-MM-DD
**Author:** [Name]

## Context

[What is motivating this decision?]

## Decision Drivers

- [Driver 1]

## Considered Options

### Option 1: [Name]

**Pros:** ...
**Cons:** ...

### Option 2: [Name]

**Pros:** ...
**Cons:** ...

## Decision

We will use **[Option X]** because [rationale].

## Consequences

### Positive
- [Benefit]

### Negative
- [Drawback]

### Risks
- [Risk]: [Mitigation]

## Related Decisions

- [Link to related ADR]
```

## Design Principles

- **NFRs First** — clarify Non-Functional Requirements before suggesting solutions
- **Trade-off Analysis** — every recommendation includes explicit Pros/Cons
- **Start Simple** — recommend the simplest working solution, then discuss evolution paths
- **Diagram-first** — include mermaid diagrams showing component relationships
