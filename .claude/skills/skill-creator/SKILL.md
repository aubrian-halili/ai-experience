---
name: skill-creator
description: Use when the user asks to "create a skill", "build a new skill", "make a Claude skill", mentions "skill template", or wants to extend Claude's capabilities with custom workflows.
argument-hint: "[skill name]"
---

# Skill Creator

Create new Claude Code skills following established patterns and best practices.

## References

- `@template.md` — Reusable SKILL.md template with placeholders
- `@references/best-practices.md` — Detailed design principles and quality checklist

## When to Create a Skill

### Good Candidates

- Repetitive workflows with consistent structure (e.g., PR reviews, code generation)
- Domain-specific tasks requiring specialized context (e.g., company coding standards)
- Multi-step processes that benefit from guided execution
- Tasks where output format consistency matters

### Skip Creating a Skill When

- One-off tasks that won't repeat
- Simple queries that don't need structured output
- Tasks already well-handled by existing skills

## Core Principles

| Principle | Description |
|-----------|-------------|
| Context Efficiency | Minimize token usage; load references only when needed |
| Progressive Disclosure | Start with essentials, defer details to linked files |
| Degrees of Freedom | Match constraint level to task variability |
| Fail-Safe Design | Handle missing inputs gracefully with clear guidance |

## Process

### 1. Understand Requirements

Ask clarifying questions:
- What triggers this skill? (trigger phrases)
- What inputs does it need? (arguments)
- What outputs should it produce? (format, structure)
- How variable are the outputs? (degrees of freedom)

### 2. Plan the Skill

Determine:
- Skill name (kebab-case, descriptive)
- Directory structure needs (references, scripts, examples)
- Whether templates or examples better serve the use case

### 3. Initialize

Run the init script to create boilerplate:

```bash
./.claude/skills/skill-creator/scripts/init-skill.sh [skill-name]
```

### 4. Author the SKILL.md

Edit the generated SKILL.md:

1. **Frontmatter**: Set name, description with trigger phrases, argument-hint
2. **Introduction**: One-line purpose statement
3. **When to Use**: Clear inclusion/exclusion criteria
4. **Process**: Step-by-step workflow
5. **Response Format**: Expected output structure
6. **Error Handling**: How to handle edge cases
7. **Related Skills**: Cross-references to complementary skills

### 5. Validate

Run validation to check structure:

```bash
./.claude/skills/skill-creator/scripts/validate-skill.sh [skill-name]
```

### 6. Iterate

Test the skill with real invocations and refine based on:
- Missing edge cases
- Unclear instructions
- Output format issues

## Skill Anatomy

| Section | Purpose | Required |
|---------|---------|----------|
| Frontmatter | Metadata for skill discovery and invocation | Yes |
| Introduction | Quick orientation on skill purpose | Yes |
| When to Use | Helps Claude decide if skill applies | Recommended |
| Process | Step-by-step execution guide | Yes |
| Response Format | Output structure expectations | Recommended |
| Error Handling | Graceful degradation guidance | Recommended |
| Related Skills | Cross-references for discovery | Optional |

## Frontmatter Reference

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `name` | string | Skill identifier (kebab-case) | Yes |
| `description` | string | Trigger phrases and purpose | Yes |
| `argument-hint` | string | Placeholder shown to user | Optional |
| `disable-model-invocation` | boolean | Prevent Claude auto-triggering (use for action skills like `/commit`, `/pr`) | Optional |
| `user-invocable` | boolean | Hide from `/` menu if false (for internal/helper skills) | Optional |
| `model` | string | Override model for skill (e.g., `haiku`, `sonnet`, `opus`) | Optional |
| `context` | string | Run in forked subagent if set to `fork` | Optional |
| `agent` | string | Subagent type when context is forked (e.g., `Explore`, `Plan`) | Optional |
| `hooks` | object | Skill-scoped hooks configuration | Optional |

## Error Handling

| Scenario | Response |
|----------|----------|
| No skill name provided | Prompt for skill name with examples |
| Invalid skill name format | Explain kebab-case requirement |
| Skill already exists | Warn and ask for confirmation to overwrite |
| Missing required section | Guide user to complete the section |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/explore` | To understand existing skill implementations |
| `/review` | To review a skill before finalizing |
| `/clean-code` | To refactor an existing skill |
