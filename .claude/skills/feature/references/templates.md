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

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | Low/Med/High | Low/Med/High | [Strategy] |

### Open Questions

- [ ] [Question that needs resolution]
```

## Incremental Delivery Patterns

### Vertical Slice

Deliver end-to-end functionality for a narrow use case:

```
Slice 1: Create basic entity (full stack)
Slice 2: Add validation (full stack)
Slice 3: Add advanced features (full stack)
```

**Best for**: Getting feedback early, validating integration points, demonstrating progress quickly.

### Horizontal Layer

Build foundation first, then add capabilities:

```
Layer 1: Domain model complete
Layer 2: All services complete
Layer 3: All endpoints complete
```

**Best for**: When dependencies are clear, team can parallelize, architecture is well-defined.

### Feature Flags

For gradual rollout:

```typescript
if (featureFlags.isEnabled('new-feature')) {
  // New implementation
} else {
  // Existing behavior
}
```

**Best for**: Risk mitigation, A/B testing, gradual rollout to users, easy rollback.

