# Feature Development Templates

## Milestone Plan Template

Use this template during Step 2 (Design & Present) to structure the implementation plan.

```markdown
## Implementation Plan

**Feature**: [Name]
**Complexity**: [Low | Medium | High]
**Architecture**: [Minimal Changes | Clean Architecture | Pragmatic Balance] (from plan)
**Delivery Pattern**: [Vertical Slice | Horizontal Layer | Feature Flags]

---

### Definition of Done (from plan)

Observable truths that must be TRUE when this feature is complete:

#### Artifacts
- [ ] [Specific file/code that must exist]

#### Behavior
- [ ] [Specific runtime behavior that must be verifiable]

#### Integration
- [ ] [Specific wiring/connection that must be in place]

#### Quality
- [ ] [Specific test/pattern requirement]

---

### Milestone N: [Name]
**Goal**: [What this milestone delivers]

**Tasks**:
- [ ] [Specific task]

**Verification**: [How to verify completion]

---

```

## Incremental Delivery Patterns

| Pattern | When to use |
|---|---|
| **Vertical Slice** | Ship a thin end-to-end slice of one user-facing behavior; de-risks integration early |
| **Horizontal Layer** | Build one infrastructure layer (e.g., data, API, UI) before the next; suits large teams with clear ownership boundaries |
| **Feature Flags** | Ship code dark; toggle on per environment or user segment; required when you can't decouple deploy from release |
