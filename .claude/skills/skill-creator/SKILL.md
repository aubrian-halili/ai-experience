---
name: skill-creator
description: >-
  User asks to "create a new skill", "scaffold a skill", "add a skill to Claude",
  or mentions "skill template" or "SKILL.md".
  Not for: updating CLAUDE.md manually (use /doc-sync).
  Not for: creating Claude Code hooks (use /hookify).
argument-hint: "[skill name]"
disable-model-invocation: true
allowed-tools: Bash(*/init-skill.sh *, */validate-skill.sh *), Read, Grep, Glob, Write, Edit
---

Create new Claude Code skills following established patterns and best practices. References `@template.md` for scaffolding and `@references/best-practices.md` for design principles.

## Skill Design Philosophy

- **Degrees of freedom** — match constraint level to task variability; creative tasks need principles, mechanical tasks need strict templates (see `@references/best-practices.md`)
- **Consistent naming** — use gerund form (verb + -ing) for skill names when possible; avoid vague, generic, or reserved words (see `@references/best-practices.md` for conventions)

## Input Handling

Use `$ARGUMENTS` if provided (skill name or description).

First, classify the request type:

| Type | Indicators | Approach |
|------|-----------|----------|
| **New Skill** | "create a skill", "build a skill for", skill name provided | Steps 1–7; full workflow from requirements to validation |
| **Skill Update** | "optimize", "improve", "update this skill" | Steps 1, 3–5, 7; skip init, focus on structural alignment with peers |
| **Skill Validation** | "validate", "check this skill" | Step 6 only; run validation script and report |
| **Template Question** | "how to write a skill", "skill structure" | Steps 1–2 only; explain Skill Anatomy and Frontmatter Reference |
| **Skill Review** | "review this skill", "is this skill good" | Steps 1, 3–5, 7; audit against quality checklist in `@references/best-practices.md` |

## Process

### 1. Pre-flight

- Classify request using the Input Handling table
- If `$ARGUMENTS` contains a skill name, check if it already exists in `.claude/skills/`
- Review existing skills via Glob to avoid scope overlap with the proposed skill

**Stop conditions:**
- Proposed skill duplicates an existing skill's scope → suggest updating the existing skill instead
- Request is not about skill creation or management → redirect to the appropriate skill

### 2. Gather Requirements

Ask clarifying questions:
- What triggers this skill? (natural phrases users would say)
- What inputs does it need? (`$ARGUMENTS` format)
- What outputs should it produce? (format, structure, degrees of freedom)
- Which tools does it need? (Read-only guidance vs. file-writing action)
- Should Claude auto-invoke it, or manual-only (`disable-model-invocation`)?
- Should this be a personal skill (`~/.claude/skills/`, cross-project) or project skill (`.claude/skills/`, team-shared)?

### 3. Plan and Confirm Structure

Determine and present to the user **before running the init script**:

- **Skill name**: kebab-case, descriptive, max 64 characters
- **Directory layout**: which subdirectories will be created (e.g., `references/`, `scripts/`)
- **Frontmatter fields**: proposed `allowed-tools`, `disable-model-invocation`, `argument-hint`
- **Constraint level**: high freedom (creative), medium (structured), or low (mechanical)

**Do not proceed to Step 4 until the user confirms the structure.**

### 4. Initialize

Run the init script to scaffold the boilerplate:

```bash
${CLAUDE_SKILL_DIR}/scripts/init-skill.sh [skill-name]
```

This creates the skill directory and a SKILL.md from `@template.md` with the skill name substituted.

### 5. Author the SKILL.md

Author each section per the Skill Anatomy table below. Start with Frontmatter — set name, description with trigger phrases, argument-hint, and allowed-tools (see Frontmatter Reference below).

Cross-reference `@references/best-practices.md` for anti-patterns and quality checklist.

### 6. Validate

Run validation to check structure:

```bash
${CLAUDE_SKILL_DIR}/scripts/validate-skill.sh [skill-name]
```

Verify against the quality checklist: Discoverable, Efficient, Graceful, Connected (see `@references/best-practices.md`).

### 7. Iterate

Test the skill with real invocations and refine.

## Skill Anatomy

| Section | Purpose | Required |
|---------|---------|----------|
| Frontmatter | Metadata for skill discovery and invocation | Yes |
| Introduction | Quick orientation (no H1 heading) | Yes |
| [Domain] Philosophy | 3-5 guiding principles | Yes |
| Input Handling | Maps input types to intent, approach, and `(none)` case | Yes |
| Process | Step-by-step with Pre-flight and stop conditions | Yes |
| Output Principles | Bold-dash bullets on what good output looks like | Yes |
| Error Handling | Scenario table + closing "Never..." principle | Yes |
| Related Skills | Cross-references with "When to Use Instead" | Recommended |
| Iron Laws / Rationalization Guard | Skill-specific guardrails (optional) | No |

## Frontmatter Reference

| Field | Type | Description | Required | Usage |
|-------|------|-------------|----------|-------|
| `name` | string | Skill identifier; lowercase letters, numbers, hyphens only (max 64 chars). Becomes the `/slash-command`. If omitted, uses directory name. | No (recommended) | Common |
| `description` | string | Trigger phrases and purpose. Claude uses this to decide when to auto-invoke. If omitted, uses first paragraph of markdown. | Recommended | Common |
| `argument-hint` | string | Placeholder shown during autocomplete (e.g., `[issue-number]`, `[filename] [format]`) | No | Common |
| `allowed-tools` | string | Tools available without per-use approval when skill is active (e.g., `Read, Grep, Glob`) | No | Common |
| `disable-model-invocation` | boolean | Prevent Claude auto-triggering; use for action skills like `/pr`, `/jira` that should be manual-only | No | Common |
| `user-invocable` | boolean | Set `false` to hide from `/` menu; use for background knowledge skills | No | Advanced |
| `model` | string | Override model for skill execution (e.g., `haiku`, `sonnet`, `opus`) | No | Advanced |
| `context` | string | Set to `fork` to run in isolated subagent context (no conversation history) | No | Advanced |
| `agent` | string | Subagent type when `context: fork` (e.g., `Explore`, `Plan`, `general-purpose`, or custom from `.claude/agents/`) | No | Advanced |
| `hooks` | object | Skill-scoped hooks configuration (see Hooks documentation) | No | Advanced |
| `effort` | string | Reasoning effort level: `low`, `medium`, `high`, `max` (Opus 4.6 only). Overrides session effort. | No | Advanced |
| `paths` | string/list | Glob patterns limiting when skill auto-activates based on files being worked on (e.g., `"**/*.ts"`) | No | Advanced |
| `shell` | string | Shell for `` !`command` `` blocks: `bash` (default) or `powershell` | No | Advanced |

See `@references/best-practices.md` for string substitution variables and dynamic context injection.

## Output Principles

- **Scaffold, don't over-specify** — generate the structural skeleton with clear placeholders; let the skill author fill in domain-specific content rather than guessing it
- **Inline references** — wire up `@references/` links within process steps, not as a standalone References section; this teaches skills to load context only when needed

## Error Handling

| Scenario | Response |
|----------|----------|
| Skill already exists | Warn user, ask whether to update existing skill or choose a different name |
| Skill scope overlaps existing skill | Show the overlapping skill, suggest extending it instead of creating a duplicate |
| Validation script reports warnings | Distinguish errors from warnings; fix errors, evaluate warnings case-by-case |
| Generated skill too long (>500 lines) | Move supplementary content to `references/` files; keep SKILL.md under 500 lines per official guidance |

Never create a skill without running validation — an unvalidated skill may fail silently when invoked.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Review or refactor an existing skill for quality and maintainability |
| `/hookify` | Creating Claude Code hooks, not skills |
