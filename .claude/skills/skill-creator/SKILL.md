---
name: skill-creator
description: >-
  TRIGGER when: user asks to "create a new skill", "build a skill", "scaffold a skill", "add a skill to
  Claude", mentions "skill template" or "SKILL.md".
  DO NOT TRIGGER when: user wants to update CLAUDE.md after creating a skill (use /config-management) or
  wants general documentation (use /docs).
argument-hint: "[skill name]"
allowed-tools: Bash, Read, Grep, Glob, Write, Edit
---

Create new Claude Code skills following established patterns and best practices. References `@template.md` for scaffolding and `@references/best-practices.md` for design principles.

## Skill Design Philosophy

- **Context efficiency** — minimize token usage; front-load critical instructions in SKILL.md and defer supplementary detail to `@references/` files
- **Progressive disclosure** — start with essentials (frontmatter, opening paragraph, process); let reference files carry depth so skills stay scannable
- **Degrees of freedom** — match constraint level to task variability; creative tasks need principles, mechanical tasks need strict templates (see `@references/best-practices.md`)
- **Fail-safe design** — handle missing inputs with clear guidance and stop conditions; a skill that silently proceeds with wrong assumptions is worse than one that asks
- **Consistent naming** — use gerund form (verb + -ing) for skill names when possible; avoid vague, generic, or reserved words (see `@references/best-practices.md` for conventions)

## When to Use

### This Skill Is For

- Repetitive workflows with consistent structure (e.g., PR reviews, code generation)
- Domain-specific tasks requiring specialized context (e.g., company coding standards)
- Multi-step processes that benefit from guided execution
- Tasks where output format consistency matters

### Use a Different Approach When

- One-off tasks that won't repeat
- Simple queries that don't need structured output
- Tasks already well-handled by existing skills → check `/explore` to find them

## Input Classification

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

- Classify request using the Input Classification table
- If `$ARGUMENTS` contains a skill name, validate it is kebab-case (`^[a-z][a-z0-9]*(-[a-z0-9]+)*$`)
- Check if a skill with that name already exists in `.claude/skills/`
- Review existing skills via Glob to avoid overlap with the proposed skill's scope

**Stop conditions:**
- No `$ARGUMENTS` and no skill description provided → ask user for a skill name or description of the workflow they want to automate
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

### 3. Plan Structure

Determine:
- Skill name (kebab-case, descriptive, max 64 characters)
- Directory structure needs (references, scripts, examples)
- Whether templates or examples better serve the use case (see `@references/best-practices.md`, Output Pattern Selection)
- Constraint level: high freedom (creative), medium (structured), or low (mechanical)

### 4. Initialize

Run the init script to scaffold the boilerplate:

```bash
${CLAUDE_SKILL_DIR}/scripts/init-skill.sh [skill-name]
```

This creates the skill directory and a SKILL.md from `@template.md` with the skill name substituted.

### 5. Author the SKILL.md

Edit the generated SKILL.md following the optimized skill pattern:

1. **Frontmatter**: Set name, description with trigger phrases, argument-hint, allowed-tools (see Frontmatter Reference below)

> **Context budget**: Descriptions are always in context for auto-invocable skills. Keep under 500 chars. Set `disable-model-invocation: true` for action skills to exclude from auto-invoke context.

2. **Opening paragraph**: One-line purpose statement (no H1 heading)
3. **Philosophy**: 3–5 bold-dash principles that guide the skill's decisions
4. **When to Use**: Clear inclusion/exclusion criteria with skill cross-references
5. **Input Classification**: Table mapping request types to indicators and process step emphasis
6. **Process**: Numbered steps with Pre-flight (including stop conditions), bullet-list sub-steps, and branching for different input types
7. **Output Principles**: 3–4 bold-dash bullets describing what good output looks like
8. **Argument Handling**: Table mapping argument types to behaviors
9. **Error Handling**: 6–8 scenarios in a table + closing "Never..." principle
10. **Related Skills**: 4–5 entries with "When to Use Instead" descriptions

Cross-reference `@references/best-practices.md` for anti-patterns and quality checklist.

### 6. Validate

Run validation to check structure:

```bash
${CLAUDE_SKILL_DIR}/scripts/validate-skill.sh [skill-name]
```

Verify against the quality checklist: Discoverable, Scoped, Efficient, Guided, Graceful, Connected, Tested (see `@references/best-practices.md`).

### 7. Iterate

Test the skill with real invocations and refine based on:
- Missing edge cases or input types
- Unclear instructions that cause wrong behavior
- Output format issues or missing context
- Comparison against peer skills for structural consistency

## Skill Anatomy

| Section | Purpose | Required |
|---------|---------|----------|
| Frontmatter | Metadata for skill discovery and invocation | Yes |
| Introduction | Quick orientation (no H1 heading) | Yes |
| [Domain] Philosophy | 3-5 guiding principles | Yes |
| When to Use | Inclusion/exclusion criteria | Yes |
| Input Classification | Maps request types to workflow variations | Yes |
| Process | Step-by-step with Pre-flight and stop conditions | Yes |
| Output Principles | Bold-dash bullets on what good output looks like | Yes |
| Argument Handling | Table mapping argument types to behaviors | Yes |
| Error Handling | Scenario table + closing "Never..." principle | Yes |
| Related Skills | Cross-references with "When to Use Instead" | Recommended |

## Frontmatter Reference

| Field | Type | Description | Required | Usage |
|-------|------|-------------|----------|-------|
| `name` | string | Skill identifier; lowercase letters, numbers, hyphens only (max 64 chars). Becomes the `/slash-command`. If omitted, uses directory name. | No (recommended) | Common |
| `description` | string | Trigger phrases and purpose. Claude uses this to decide when to auto-invoke. If omitted, uses first paragraph of markdown. | Recommended | Common |
| `argument-hint` | string | Placeholder shown during autocomplete (e.g., `[issue-number]`, `[filename] [format]`) | No | Common |
| `allowed-tools` | string | Tools available without per-use approval when skill is active (e.g., `Read, Grep, Glob`) | No | Common |
| `disable-model-invocation` | boolean | Prevent Claude auto-triggering; use for action skills like `/commit`, `/pr` that should be manual-only | No | Common |
| `user-invocable` | boolean | Set `false` to hide from `/` menu; use for background knowledge skills | No | Advanced |
| `model` | string | Override model for skill execution (e.g., `haiku`, `sonnet`, `opus`) | No | Advanced |
| `context` | string | Set to `fork` to run in isolated subagent context (no conversation history) | No | Advanced |
| `agent` | string | Subagent type when `context: fork` (e.g., `Explore`, `Plan`, `general-purpose`, or custom from `.claude/agents/`) | No | Advanced |
| `hooks` | object | Skill-scoped hooks configuration (see Hooks documentation) | No | Advanced |

**String substitution variables** available in skill content:
- `$ARGUMENTS` — all arguments passed when invoking the skill
- `$ARGUMENTS[N]` or `$N` — specific argument by 0-based index
- `${CLAUDE_SESSION_ID}` — unique session identifier; useful for per-session logging or temp file isolation
- `${CLAUDE_SKILL_DIR}` — absolute path to the skill's directory; use in `` !`command` `` or Bash steps to reference bundled scripts/files portably
- `` !`command` `` — dynamic context; shell command output replaces the placeholder before skill content is sent to Claude

## Output Principles

- **Scaffold, don't over-specify** — generate the structural skeleton with clear placeholders; let the skill author fill in domain-specific content rather than guessing it
- **Optimized pattern by default** — every generated skill should include the standard sections (Philosophy, Input Classification, Process with Pre-flight, Output Principles, Argument Handling, Error Handling, Related Skills)
- **Inline references** — wire up `@references/` links within process steps, not as a standalone References section; this teaches skills to load context only when needed
- **Validate before done** — always run the validation script and quality checklist before presenting the skill as complete

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Ask user for a skill name or description of the workflow to automate |
| Skill name (e.g., `deploy`) | Start full creation workflow with that name |
| Skill name + description (e.g., `deploy production deployment workflow`) | Start creation with name and use description to pre-fill requirements |
| `validate [skill-name]` | Run validation script only |
| `optimize [skill-name]` | Audit existing skill against optimized pattern, recommend structural improvements |

## Error Handling

| Scenario | Response |
|----------|----------|
| No skill name provided | Ask for a skill name with examples of good kebab-case names |
| Invalid skill name format | Explain kebab-case requirement: lowercase letters, numbers, hyphens (max 64 chars) |
| Skill already exists | Warn user, ask whether to update existing skill or choose a different name |
| Skill scope overlaps existing skill | Show the overlapping skill, suggest extending it instead of creating a duplicate |
| Missing required section in authored skill | Guide user to complete the section; reference Skill Anatomy table |
| Init script fails | Check script permissions (`chmod +x`), verify template.md exists at expected path |
| Validation script reports warnings | Distinguish errors from warnings; fix errors, evaluate warnings case-by-case |
| Generated skill too long (>500 lines) | Move supplementary content to `references/` files; keep SKILL.md under 500 lines per official guidance |

Never create a skill without running validation — an unvalidated skill may fail silently when invoked.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/explore` | Understand existing skill implementations before creating similar ones |
| `/review` | Review a skill's quality before finalizing |
| `/clean-code` | Refactor an existing skill for maintainability |
| `/typescript` | TypeScript-specific guidance for skills that produce TypeScript code |
| `/patterns` | Design patterns to implement within a skill's process |
| `/hookify` | Creating Claude Code hooks, not skills |
