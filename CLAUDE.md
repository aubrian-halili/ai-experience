# AI Experience Project

## Project Overview

- This is a Claude Code skills and configuration repository
- Skills live in `.claude/skills/<name>/SKILL.md` with optional `references/` subdirectories
- Each skill is self-contained with frontmatter metadata defining capabilities
- Skills reference each other via "Related Skills" sections for workflow integration

## Project Structure

```text
.claude/
├── agents/          # reusable subagent definitions
├── skills/          # specialized workflow skills
├── rules/           # Modular instruction files
├── scripts/         # Shell scripts (e.g. statusline.sh)
└── settings.json    # Project-wide settings
```

## External Prerequisites

Some skills depend on tooling and environment that live outside this repo. Without them the skill
cannot connect and should report a tool failure rather than working around it
(`.claude/rules/tool-reliability.md`).

| Requirement | Needed by | Notes |
|-------------|-----------|-------|
| `aurora-psql` on `PATH` | `/backoffice-database`, `database-explorer` | Read-only Aurora wrapper. Deliberately not committed — it carries the auth invocation, which stays out of a public repo. Currently at `~/.local/bin/aurora-psql` |
| `AURORA_DB_NAME` | as above | Per-market database-name **template**, e.g. `qred_{market}_db`; needs `--market` to resolve |
| `AURORA_HOST` | as above | Test host |
| `AURORA_HOST_PROD` | as above, for `--env prod-replica` | Production **reader** host template with a `{market}` segment; the wrapper refuses a non-`cluster-ro` host |
| `AURORA_LOGIN_SCRIPT`, `AURORA_DB_USER`, `AURORA_SSL_CERT` | as above | Consumed by the wrapper only |
| `AURORA_SSLMODE` | as above (optional) | Overrides `sslmode`; the wrapper defaults to `verify-full`. Set `verify-ca` for hosts that are CNAME aliases whose certificates name the underlying RDS endpoint |
| `ATLASSIAN_HOST` | `/confluence`, `/pr` | Atlassian tenant hostname. Both skills resolve it with `printenv ATLASSIAN_HOST` and ask if unset |
| `GITHUB_ORG` | `/git-repos`, `git-repos-explorer` (optional) | Overrides the org; otherwise derived from `gh api user/orgs` |

## Common Tasks

- **Planning work**: Use `/plan` skill to decompose, scope, and compare approaches before implementation
- **Implementing**: Use `/feature` skill to build an approved plan through test-driven milestones
- **Gating completion**: Use `/gate` skill for end-to-end merge-readiness (checkout + verify + review)
- **Confirming a result**: Use `/cross-check` skill to re-derive an answer or finished task independently and reconcile it claim by claim

## Testing

- No automated test suite for skill *behavior* — manual verification only
- Test skills in real scenarios before committing
- `.claude/scripts/check-skill-contracts.sh` lints skill *structure* (frontmatter fields, `name:` vs directory, `Not for:` clause, reference-path resolution including cross-skill ones, orphaned reference files). It also lints `.claude/agents/*.md` — `name:` vs filename, required frontmatter, and the reference paths agents point into a skill's `references/`. Run it after adding, renaming, or moving a skill, an agent, or a `references/` file

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
