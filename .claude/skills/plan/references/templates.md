# Plan Templates

## Architecture Comparison Template

```markdown
### Architecture Options

| Dimension | Minimal Changes | Clean Architecture | Pragmatic Balance |
|-----------|----------------|-------------------|-------------------|
| Files changed | [count] | [count] | [count] |
| New abstractions | [list or "none"] | [list] | [list] |
| Risk | [assessment] | [assessment] | [assessment] |
| Best when | [conditions] | [conditions] | [conditions] |

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

### Phase Breakdown

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
| Architecture: [Minimal Changes / Clean Architecture / Pragmatic Balance] | [Why this approach was chosen] | [When] |

### Tickets *(populated by /jira)*

```

