---
name: patterns
description: Use when the user asks "which pattern should I use", "how to implement [pattern name]", mentions "factory", "strategy", "observer", "singleton", "decorator", or discusses code structure problems that patterns could solve.
argument-hint: "[problem or pattern name]"
allowed-tools: Read, Grep, Glob
---

Provide guidance on selecting and implementing design patterns for specific problems.

## When to Use

### This Skill Is For

- Recommending design patterns for specific problems
- Explaining and implementing specific patterns
- Comparing pattern alternatives with trade-offs
- Refactoring code smells using patterns
- Validating pattern usage

### Use a Different Approach When

- Reviewing code quality → use `/clean-code` or `/review`
- Making architectural decisions → use `/architecture`
- Understanding existing code → use `/explore`

## Input Classification

Use `$ARGUMENTS` if provided (problem description or pattern name).

First, classify the request to determine the appropriate response:

| Type | Indicators | Approach |
|------|-----------|----------|
| **Problem-First** | "how do I handle...", "what pattern for..." | Analyze problem → recommend pattern → show implementation |
| **Pattern-First** | "how to implement Factory", "show me Strategy" | Explain pattern → show implementation → discuss when to use |
| **Comparison** | "Factory vs Builder", "which is better" | Compare patterns → highlight trade-offs → recommend based on context |
| **Refactoring** | "replace these switch statements", "too many conditionals" | Identify smell → suggest pattern → show transformation |
| **Validation** | "is this the right pattern", "am I using this correctly" | Review usage → validate or suggest improvements |

## Pattern Selection Guide

| Problem | Consider |
|---------|----------|
| Complex object creation | Factory, Builder |
| Adding behavior dynamically | Decorator, Strategy |
| Incompatible interfaces | Adapter, Facade |
| State-dependent behavior | State, Strategy |
| Decoupling components | Observer, Mediator |
| External service calls | Circuit Breaker, Retry |
| Distributed transactions | Saga, Outbox |

## Error Handling

| Scenario | Response |
|----------|----------|
| Partial analysis | Present findings with clear `[Incomplete]` markers |
| Uncertain recommendation | Mark as `[High Confidence]` or `[Needs Verification]` |
| Missing context | State assumptions explicitly |
| Multiple valid options | Present alternatives with trade-offs, let user decide |

Never silently commit to a pattern—surface uncertainty and let the user decide.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/clean-code` | Pattern implementation needs quality review |
| `/architecture` | Pattern choice has broader architectural implications |
| `/architecture --adr` | Pattern decision should be documented |
| `/diagram` | Pattern structure needs visualization |
| `/review` | Existing pattern usage needs evaluation |
