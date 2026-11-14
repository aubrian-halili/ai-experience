# Plan Templates

## Design Approach Template

```markdown
### Design Approach

**Follows**: [existing pattern(s) the design builds on, with file:line]
**Files changed**: [count] — **New abstractions**: [list or "none"]
**Risk**: [assessment]

**Design Forks** (carried into open decisions):
- [Choice the codebase does not settle] — [options], evidence: [file:line]

**Alternative considered** *(only when the Hexagonal architect ran)*:
| Dimension | Existing Patterns | Hexagonal |
|-----------|-------------------|-----------|
| Files changed | [count] | [count] |
| New abstractions | [list or "none"] | [ports + adapters list] |
| Risk | [assessment] | [assessment] |

**Recommendation**: [Approach] — [one sentence rationale]
```

## Session State Template (.planning/STATE.md)

```markdown
## Planning State

**Goal**: [One-sentence goal]
**Source**: [Jira ticket ID, epic, or goal description]
**Plan Created**: YYYY-MM-DD
**Last Updated**: YYYY-MM-DD

---

## Plan *(immutable once approved)*

### Definition of Done

Observable truths that must be TRUE when this goal is complete:

#### Artifacts
- [ ] [artifact]

#### Behavior
- [ ] [behavior]

#### Integration
- [ ] [integration point]

#### Quality
- [ ] [test/pattern requirement]

---

### Out of Scope

Explicit boundaries — things a reader might assume are included but are NOT, to prevent scope creep during implementation:

- [What we are deliberately NOT doing, and why]

---

### Phase Breakdown

> **Vertical slices, not horizontal layers.** Each phase must cross every layer it needs
> (migration → service → API → UI) and be independently verifiable on its own. Do NOT
> split work into horizontal layers (Phase 1: all migrations, Phase 2: all services…).
> Order phases so that if a later phase is dropped, the earlier phases still deliver
> standalone value.

#### Phase N: [Name]
**Goal**: [What this phase achieves]
**Dependencies**: None | Phase N-1
**Observable Truths Satisfied**: [List from Definition of Done]

**Files to Create**:
| File | Purpose |
|------|---------|
| `path/to/file` | [Purpose] |

**Files to Modify**:
| File | Change | Reason |
|------|--------|--------|
| `path/to/file` | [Change] | [Why] |

**Verification**:
- [ ] [Specific command or condition to verify]

---

## State *(mutable)*

### Progress

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1: [Name] | [Pending / In Progress / Complete / Blocked] | [Brief note] |
| Phase 2: [Name] | [Pending / In Progress / Complete / Blocked] | [Brief note] |

### Current Phase

**Phase**: [Current phase name]
**Status**: [In Progress / Blocked]
**Next Steps**:
1. [next action]

### Blockers

| Blocker | Impact | Resolution |
|---------|--------|------------|
| [Description] | [Which phase] | [How to resolve] |

### Key Decisions

| Decision | Rationale | Date |
|----------|-----------|------|
| Architecture: [Existing Patterns / Minimal Changes / Hexagonal] | [Why this approach was chosen] | [When] |

### Tickets *(populated by /jira)*

```

