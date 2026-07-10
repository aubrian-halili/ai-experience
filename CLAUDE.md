# AI Experience Project

## Project Overview

- This is a Claude Code skills and configuration repository
- Skills live in `.claude/skills/<name>/SKILL.md` with optional `references/` subdirectories
- Each skill is self-contained with frontmatter metadata defining capabilities
- Skills reference each other via "Related Skills" sections for workflow integration

## Project Structure

```text
.claude/
├── agents/          # 7 reusable subagent definitions
├── skills/          # 13 specialized workflow skills
├── rules/           # Modular instruction files
├── scripts/         # Shell scripts (e.g. statusline.sh)
└── settings.json    # Project-wide settings
```

## Common Tasks

- **Planning work**: Use `/plan` skill to decompose, scope, and compare approaches before implementation
- **Implementing**: Use `/feature` skill to build an approved plan through test-driven milestones
- **Gating completion**: Use `/gate` skill for end-to-end merge-readiness (checkout + verify + review)

## Testing

- No automated test suite currently — manual verification only
- Test skills in real scenarios before committing

## Architecture Decisions

- Skills follow the `SKILL.md + references/` pattern
- Frontmatter defines metadata (`name`, `description`, `allowed-tools`, `argument-hint`)
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
- `.claude/rules/tool-reliability.md` - CLI/MCP failure handling (pause and inform, never silently fall back)
