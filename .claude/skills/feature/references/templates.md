# Feature Development Templates

## Milestone Plan Template

Use this template during Step 3 (Design & Present) to structure the implementation plan.

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

### Files to Create

| File | Purpose | Tests |
|------|---------|-------|
| `path/to/file` | [Purpose] | `path/to/test` |

### Files to Modify

| File | Change | Reason |
|------|--------|--------|
| `path/to/file` | [Change] | [Why needed] |

---

### Milestone 1: Foundation
**Goal**: [What this milestone establishes]

**Tasks**:
- [ ] [Specific task]
- [ ] [Specific task]

**Verification**: [How to verify completion]

**Commit**: `feat: [commit message]`

---

### Milestone 2: Core Implementation
**Goal**: [What this milestone delivers]

**Tasks**:
- [ ] [Specific task]
- [ ] [Specific task]

**Verification**: [How to verify completion]

**Commit**: `feat: [commit message]`

---

### Milestone 3: Integration
**Goal**: [What this milestone connects]

**Tasks**:
- [ ] [Specific task]
- [ ] [Specific task]

**Verification**: [How to verify completion]

**Commit**: `feat: [commit message]`

---

```

## Incremental Delivery Patterns

Choose one: **Vertical Slice** (end-to-end per use case), **Horizontal Layer** (foundation first, then capabilities), or **Feature Flags** (gradual rollout with easy rollback).

