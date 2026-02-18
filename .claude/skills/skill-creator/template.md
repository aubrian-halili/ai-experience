---
name: [skill-name]
description: Use when the user [trigger phrases describing when this skill applies]. Examples: "[example phrase 1]", "[example phrase 2]".
argument-hint: "[argument placeholder]"
allowed-tools: [tools this skill needs, e.g., Read, Grep, Glob]
---

# [Skill Title]

<!-- One-line description of what this skill does -->

## When to Use

### This Skill Is For

- [Primary use case 1]
- [Primary use case 2]

### Use a Different Approach When

- [Exclusion case 1]
- [Exclusion case 2]

## Process

Use `$ARGUMENTS` if provided ([argument description]).

### 1. [First Step Name]

<!-- What to do first -->

### 2. [Second Step Name]

<!-- What to do next -->

### 3. [Third Step Name]

<!-- Continue as needed. Reference `@references/templates.md` for detailed response format templates if needed. -->

## Error Handling

| Scenario | Response |
|----------|----------|
| [Error case 1] | [How to handle] |
| [Error case 2] | [How to handle] |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/[related-skill]` | [When that skill is more appropriate] |
