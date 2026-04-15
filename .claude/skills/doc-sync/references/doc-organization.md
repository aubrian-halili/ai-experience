# Documentation Organization Best Practices

Guidelines for structuring project documentation so Claude can discover and load context efficiently.

## The Three-Tier Principle

Claude loads documentation in a strict hierarchy. Placing content in the wrong tier means it either wastes context on every interaction or gets missed when it matters most.

| Tier | Location | When Loaded | What Belongs Here |
|------|----------|-------------|-------------------|
| **Always-on** | `CLAUDE.md`, `.claude/rules/*.md` | Every session start | Project identity, non-obvious conventions, architectural decisions (the "why"), gotchas |
| **Invocation-triggered** | Skill/agent bodies | When invoked | Workflow instructions, task-specific guidance |
| **Step-triggered** | `docs/`, `references/`, linked files | When explicitly loaded | API references, detailed guides, ADRs, runbooks, schemas |

Always-on context costs context budget on every interaction — keep it lean and high-signal.

## CLAUDE.md Sizing Guidelines

**Target: 50–150 lines** for most projects.

**What belongs in CLAUDE.md:**
- Project purpose (1-3 sentences max)
- Key architectural decisions — the "why", not the "what" (e.g., "We use event sourcing because compliance requires full audit history")
- Non-obvious conventions that differ from framework defaults
- Known gotchas (footguns, subtle dependencies, environment setup caveats)
- Common tasks as quick commands
- Pointers to deeper documentation ("Architecture decisions live in `docs/architecture/`")

**What does NOT belong in CLAUDE.md:**
- File listings (a fresh agent can run `ls`)
- Technology stack restated from `package.json`/`go.mod`/etc.
- Step-by-step tutorials (put in `docs/`)
- Exhaustive API references (put in `docs/`)

**If CLAUDE.md exceeds 200 lines:** Extract sections into either `.claude/rules/` (if they're always-applicable conventions) or `docs/` (if they're reference material), then replace the section with a one-line pointer.

## When to Use `.claude/rules/`

Use `.claude/rules/` for conventions that should apply to **every interaction**:
- Code style and formatting preferences
- Git branch/commit naming conventions
- Testing approach and TDD expectations
- Security guidelines that apply universally
- Debugging methodology

**Structure:** One concern per file, named descriptively (`git-conventions.md`, `testing.md`). Keep each file under 80 lines — these are auto-loaded and accumulate across all rule files.

**Do not use for:** Reference material, project-specific deep dives, or content only relevant to specific tasks.

## When to Use `docs/`

Use `docs/` for material that is **only needed for specific tasks**:
- API reference (load when building against the API)
- Architecture decision records — `docs/architecture/decisions/adr-NNN-*.md`
- Runbooks (load when debugging production issues)
- Onboarding guides
- Data models and schemas
- Integration guides for third-party services

**Always reference docs/ from CLAUDE.md** so agents know the folder exists and what it contains. Without a pointer, agents won't know to look there.

Example CLAUDE.md pointer:
```markdown
## Documentation

- Architecture decisions: `docs/architecture/decisions/` (ADR format)
- API reference: `docs/api/` (OpenAPI spec + examples)
- Runbooks: `docs/runbooks/` (incident response, deploys)
```

## Documentation as Exploration Accelerant

When a fresh agent starts work on a feature, the first thing it does is explore the codebase. Good documentation shortens this exploration loop significantly.

**A good CLAUDE.md answers:**
1. What is this project and what problem does it solve?
2. What is the key architectural shape? (What are the main components and how do they interact?)
3. What is non-obvious about how this codebase works?
4. Where do I look for more detail on topic X?

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
