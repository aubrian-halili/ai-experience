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

## Input Handling

Use `$ARGUMENTS` if provided (skill name or description).

First, classify the request type:

| Type | Indicators | Approach |
|------|-----------|----------|
| **New Skill** | "create a skill", "build a skill for", skill name provided | Steps 1–6; full workflow from requirements to validation |
| **Skill Update** | "optimize", "improve", "update this skill" | Steps 1, 3–5; skip init, focus on structural alignment with peers |
| **Skill Validation** | "validate", "check this skill" | Step 6 only; run validation script and report |
| **Template Question** | "how to write a skill", "skill structure" | Steps 1–2 only; walk through `@template.md` structure |
| **Skill Review** | "review this skill", "is this skill good" | Steps 1, 3–5; audit against quality checklist in `@references/best-practices.md` |

## Process

### 1. Pre-flight

- If `$ARGUMENTS` contains a skill name, check if it already exists in `.claude/skills/`; if so, suggest updating the existing skill instead of creating a new one

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

Follow the section structure in `@template.md`. Start with Frontmatter — set name, description with trigger phrases, argument-hint, and allowed-tools.

Cross-reference `@references/best-practices.md` for anti-patterns and quality checklist. Keep SKILL.md under 500 lines; move supplementary content to `references/`.

### 6. Validate

Run validation to check structure:

```bash
${CLAUDE_SKILL_DIR}/scripts/validate-skill.sh [skill-name]
```

Verify against the quality checklist: Discoverable, Efficient, Graceful, Connected (see `@references/best-practices.md`).

## Output Principles

- **Inline references** — wire up `@references/` links within process steps, not as a standalone References section; this teaches skills to load context only when needed

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Review or refactor an existing skill for quality and maintainability |
| `/hookify` | Creating Claude Code hooks, not skills |
