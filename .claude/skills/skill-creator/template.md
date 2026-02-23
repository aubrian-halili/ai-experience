---
name: [skill-name]
description: Use when the user [trigger phrases describing when this skill applies]. Examples: "[example phrase 1]", "[example phrase 2]".
argument-hint: "[argument placeholder]"
allowed-tools: [tools this skill needs, e.g., Read, Grep, Glob]
# disable-model-invocation: true  # Uncomment for manual-only skills (e.g., /commit, /deploy)
# user-invocable: false            # Uncomment to hide from / menu (background knowledge)
# model: sonnet                    # Uncomment to override model: haiku, sonnet, opus
# context: fork                    # Uncomment to run in isolated subagent context
# agent: Explore                   # Required when context: fork (Explore, Plan, general-purpose)
# hooks:                           # Uncomment for skill-scoped hooks configuration
---

<!-- One-line description of what this skill does. No H1 heading. -->

## [Domain] Philosophy

- **[Principle 1]** — [explanation]
- **[Principle 2]** — [explanation]
- **[Principle 3]** — [explanation]

## When to Use

### This Skill Is For

- [Primary use case 1]
- [Primary use case 2]
- [Primary use case 3]

### Use a Different Approach When

- [Exclusion case 1] → use `/[other-skill]`
- [Exclusion case 2] → use `/[other-skill]`

## Input Classification

Use `$ARGUMENTS` if provided ([argument description]).

First, classify the request type:

| Type | Indicators | Approach |
|------|-----------|----------|
| **[Type 1]** | [trigger phrases] | Steps 1–N; emphasis on [step] |
| **[Type 2]** | [trigger phrases] | Steps 1–N; emphasis on [step] |

## Process

### 1. Pre-flight

- Classify request using the Input Classification table
- [Pre-flight check 1]
- [Pre-flight check 2]

**Stop conditions:**
- [Condition 1] → [action]
- [Condition 2] → [action]

### 2. [Step Name]

- [Sub-step with bullets]
- [Sub-step with bullets]

### 3. [Step Name]

- [Sub-step with bullets]
- [Sub-step with bullets]

## Output Principles

- **[Principle 1]** — [explanation]
- **[Principle 2]** — [explanation]

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | [What to do when no argument is provided] |
| [Argument type] | [Behavior] |

## Error Handling

| Scenario | Response |
|----------|----------|
| [Error case 1] | [How to handle] |
| [Error case 2] | [How to handle] |

Never [closing principle about what the skill should never silently do].

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/[related-skill]` | [When that skill is more appropriate] |
