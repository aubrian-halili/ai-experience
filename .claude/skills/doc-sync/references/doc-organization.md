# Documentation Organization Best Practices

## The Three-Tier Principle

Claude loads documentation in a strict hierarchy. Placing content in the wrong tier means it either wastes context on every interaction or gets missed when it matters most.

| Tier | Location | When Loaded | What Belongs Here |
|------|----------|-------------|-------------------|
| **Always-on** | `CLAUDE.md`, `.claude/rules/*.md` | Every session start | Project identity, non-obvious conventions, architectural decisions (the "why"), gotchas |
| **Invocation-triggered** | Skill/agent bodies | When invoked | Workflow instructions, task-specific guidance |
| **Step-triggered** | `docs/`, `references/`, linked files | When explicitly loaded | API references, detailed guides, ADRs, runbooks, schemas |

## CLAUDE.md Sizing Guidelines

**Target: 50–150 lines** for most projects.

**What belongs in CLAUDE.md:**
- Project purpose (1-3 sentences max)
- Key architectural decisions — the "why", not the "what" (e.g., "We use event sourcing because compliance requires full audit history")
- Non-obvious conventions that differ from framework defaults
- Known gotchas (footguns, subtle dependencies, environment setup caveats)
- Common tasks as quick commands
- Pointers to deeper documentation ("Architecture decisions live in `docs/architecture/`")

**If CLAUDE.md exceeds 200 lines:** Extract sections into either `.claude/rules/` (if they're always-applicable conventions) or `docs/` (if they're reference material), then replace the section with a one-line pointer.

## `.claude/rules/` and `docs/`

- `.claude/rules/`: one concern per file, named descriptively, keep each file under 80 lines
- `docs/`: architecture decision records live at `docs/architecture/decisions/adr-NNN-*.md`

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
