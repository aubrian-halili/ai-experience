# Documentation Organization Best Practices

## The Three-Tier Principle

| Tier | Location | When Loaded | What Belongs Here |
|------|----------|-------------|-------------------|
| **Always-on** | `CLAUDE.md`, `.claude/rules/*.md` | Every session start | Project identity, non-obvious conventions, architectural decisions (the "why"), gotchas |
| **Invocation-triggered** | Skill/agent bodies | When invoked | Workflow instructions, task-specific guidance |
| **Step-triggered** | `docs/`, `references/`, linked files | When explicitly loaded | API references, detailed guides, ADRs, runbooks, schemas |

## CLAUDE.md Sizing Guidelines

**Target: 50–150 lines** for most projects.

## Monorepo Structure Note

```
CLAUDE.md                    # Monorepo overview + which packages exist + how they relate
packages/
  <package>/
    CLAUDE.md                # Package-specific context (optional, for complex packages)
docs/
  architecture/
  runbooks/
```

For monorepos, the root CLAUDE.md should explain the package topology and cross-package dependencies — this is almost never derivable from code alone.
