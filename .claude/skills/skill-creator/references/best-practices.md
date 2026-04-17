# Skill Design Best Practices

## Context Window Principles

Skills consume context tokens. The system budget is ~2% of the context window (~16,000 chars as a practical fallback). Override with the `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable if skills need more room. Keep SKILL.md under 500 lines; move supplementary content to `references/`.

## CSO Principle: Description as Trigger, Not Summary

The `description` field serves as the **Context-Sensitive Orchestration (CSO)** trigger — it tells Claude _when_ to invoke the skill, not _what_ it does. Include ONLY trigger conditions (user phrases, keywords, situations).

**Good:** `Use when the user asks to "debug this", "fix this bug", "why is this failing", or encounters unexpected behavior.`

**Bad:** `Systematically diagnose bugs using reproduce-isolate-hypothesize-fix-verify methodology with built-in guards against analysis paralysis.`

## Degrees of Freedom

Match constraint level to task variability:

- **High** (creative): principles and examples, not templates
- **Medium** (structured): flexible templates with required elements
- **Low** (mechanical): strict templates with format validation

## Quality Checklist

Before finalizing a skill:

- [ ] **Discoverable**: Description contains natural trigger phrases
- [ ] **Efficient**: No unnecessary context loading
- [ ] **Connected**: Links to related skills where appropriate

