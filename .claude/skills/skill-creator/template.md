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
# effort: medium                   # Uncomment to set reasoning effort: low, medium, high, max (Opus 4.6)
# paths: ["**/*.ts"]               # Uncomment to limit auto-activation by file glob patterns
# shell: bash                      # Uncomment to set shell for !<command>: bash, powershell
---

<!-- String substitution variables: $ARGUMENTS (all args), $ARGUMENTS[N] or $N (by index), ${CLAUDE_SESSION_ID} (session ID), ${CLAUDE_SKILL_DIR} (skill directory path), (shell output) -->

<!-- One-line description of what this skill does. No H1 heading. -->

## [Domain] Philosophy

- **[Principle 1]** — [explanation]
- **[Principle 2]** — [explanation]
- **[Principle 3]** — [explanation]

## Input Handling

Use `$ARGUMENTS` if provided ([argument description]).

First, classify the request type:

| Type | Indicators | Approach |
|------|-----------|----------|
| **[Type 1]** | [trigger phrases] | Steps 1–N; emphasis on [step] |
| **[Type 2]** | [trigger phrases] | Steps 1–N; emphasis on [step] |
| **(none)** | No arguments provided | [How to handle missing input — ask, use defaults, or stop] |

## Process

### 1. Pre-flight

- Classify request using the Input Handling table
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
