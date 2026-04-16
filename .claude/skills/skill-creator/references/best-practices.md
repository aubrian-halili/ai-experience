# Skill Design Best Practices

## Context Window Principles

Skills consume context tokens. The system budget is ~2% of the context window (~16,000 chars as a practical fallback). Override with the `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable if skills need more room.

## CSO Principle: Description as Trigger, Not Summary

The `description` field serves as the **Context-Sensitive Orchestration (CSO)** trigger — it tells Claude _when_ to invoke the skill, not _what_ it does. Include ONLY trigger conditions (user phrases, keywords, situations).

**Good:** `Use when the user asks to "debug this", "fix this bug", "why is this failing", or encounters unexpected behavior.`

**Bad:** `Systematically diagnose bugs using reproduce-isolate-hypothesize-fix-verify methodology with built-in guards against analysis paralysis.`

## Degrees of Freedom

Match constraint level to task variability:

### High Freedom (Creative Tasks)

- Provide principles, not templates
- Use examples to illustrate range of acceptable outputs

### Medium Freedom (Structured Tasks)

- Provide flexible templates with optional sections
- Define required elements, allow variation in presentation

### Low Freedom (Mechanical Tasks)

- Provide strict templates with placeholders
- Specify exact format, validate output structure

## Quality Checklist

Before finalizing a skill:

- [ ] **Discoverable**: Description contains natural trigger phrases
- [ ] **Efficient**: No unnecessary context loading
- [ ] **Graceful**: Handles missing inputs and edge cases
- [ ] **Connected**: Links to related skills where appropriate

## Dynamic Context Injection

Use `!<command>` to inject shell output before skill content is sent to Claude. Example: `` Current branch: !`git rev-parse --abbrev-ref HEAD` `` resolves to `Current branch: feature/auth-flow` at runtime.

## Extended Thinking

Include the keyword **"ultrathink"** in skill content to activate extended thinking mode. Use for complex analysis, architecture decisions, or security audits where reasoning depth meaningfully improves results. Tradeoff: higher latency and token usage.


