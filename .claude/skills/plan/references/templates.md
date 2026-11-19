# Plan Templates

## Design Approach Template

```markdown
### Design Approach

**Follows**: [existing pattern(s) the design builds on, with file:line]
**Files changed**: [count] — **New abstractions**: [list or "none"]
**Risk**: [assessment]

**Design Forks** (carried into open decisions): [fork names, each briefed per the Decision Option Template below], or "none"

**Alternative considered** *(only when the Hexagonal architect ran)*:
| Dimension | Existing Patterns | Hexagonal |
|-----------|-------------------|-----------|
| Files changed | [count] | [count] |
| Affected areas | [modules / layers] | [modules / layers] |
| New abstractions | [list or "none"] | [ports + adapters list] |
| Effort | [S/M/L] | [S/M/L] |
| Risk | [assessment] | [assessment] |

**Recommendation**: [Approach] — [one sentence rationale]
```

## Decision Option Template

Used for every `AskUserQuestion` in §4.1. Field names follow the Blocking finding shape in
`.claude/skills/gate/references/templates.md`, so plans and reviews read the same way. The dialog
may hide everything printed before it, so each question must stand on its own.

Write each option **after reading its cited code yourself**, in your own words — never paste the
architect's fork table. If an option's claims do not hold up in the code, drop or correct it.

**question** — the decision plus one sentence of context: what it affects and why the codebase
does not settle it.

**option `label`** — 1–5 words; append ` (Recommended)` to the recommended option and list it first.

**option `description`** — one line: `Effort [S/M/L] · [N] files · [main trade-off]`.

**option `preview`**:

~~~markdown
- **What changes**: [1–2 plain sentences describing the option concretely]
- **Affected areas** ([N] files; phases touched: [1, 3]):
  - `path/to/file_a` — modify: [what]
  - `path/to/module_b/` — new: [what]
- **Effort**: [S/M/L] — [doc/test/type edit | adds mechanism: …]; [written rule it must follow, or "none found"]
- **Impact**: [what this option enables or breaks, and who notices]
- **Likelihood**: [how likely its main downside is to bite, under what conditions; evidence]
- **Reversibility**: [easy | needs migration | hard to undo]
- **Trade-off**: [what you gain vs. what you give up, vs. the other options]
- **Evidence**: `file:line` [that grounds this option]
- Confidence: [verified … / assumed …]
~~~

**Effort scale** (relative, never hours): **S** = ≤3 files, no new abstraction; **M** = 4–10
files or one new abstraction; **L** = >10 files, a migration, or a new integration.

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

