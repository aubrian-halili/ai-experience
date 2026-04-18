# AI Experience Project

## Project Overview

- This is a Claude Code skills and configuration repository
- Skills live in `.claude/skills/<name>/SKILL.md` with optional `references/` subdirectories
- Each skill is self-contained with frontmatter metadata defining capabilities
- Skills reference each other via "Related Skills" sections for workflow integration

## Project Structure

```text
.claude/
├── agents/          # 5 reusable subagent definitions
├── skills/          # 15 specialized workflow skills
├── rules/           # Modular instruction files
└── settings.json    # Project-wide settings
```

## Common Tasks

- **Creating PRs**: Use `/pr` skill for auto-generated titles/descriptions
- **Code review**: Use `/review` skill for multi-dimensional analysis

## Testing

- No automated test suite currently — manual verification only
- Test skills in real scenarios before committing

## Architecture Decisions

- Skills follow the `SKILL.md + references/` pattern
- Frontmatter defines metadata (name, description, tools, context)
- Reference materials split into separate files for maintainability
- Skills integrate via cross-references, not direct dependencies

## Conventions

Detailed conventions are maintained in modular rule files:

- `.claude/rules/git-conventions.md` - Branch naming, commit format, Jira integration
- `.claude/rules/code-style.md` - TypeScript, formatting, diagrams
- `.claude/rules/pr-conventions.md` - PR titles, descriptions, review process
- `.claude/rules/debug.md` - Debugging methodology and guardrails
- `.claude/rules/testing.md` - TDD enforcement and testing pyramid
- `.claude/rules/architecture.md` - ADR template and conventions
- `.claude/rules/security.md` - STRIDE/DREAD assessment and agent orchestration
