---
name: patterns
description: Use when the user asks "which pattern should I use", "how to implement [pattern name]", mentions "factory", "strategy", "observer", "singleton", "decorator", or discusses code structure problems that patterns could solve.
argument-hint: "[problem or pattern name]"
---

Provide guidance on selecting and implementing design patterns for specific problems.

## Input Classification

First, classify the request to determine the appropriate response:

| Type | Indicators | Approach |
|------|-----------|----------|
| **Problem-First** | "how do I handle...", "what pattern for..." | Analyze problem → recommend pattern → show implementation |
| **Pattern-First** | "how to implement Factory", "show me Strategy" | Explain pattern → show implementation → discuss when to use |
| **Comparison** | "Factory vs Builder", "which is better" | Compare patterns → highlight trade-offs → recommend based on context |
| **Refactoring** | "replace these switch statements", "too many conditionals" | Identify smell → suggest pattern → show transformation |
| **Validation** | "is this the right pattern", "am I using this correctly" | Review usage → validate or suggest improvements |

Select the approach before proceeding—this shapes the response structure.

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

## Categories

**Creational**: Factory, Abstract Factory, Builder, Singleton, Prototype
**Structural**: Adapter, Bridge, Composite, Decorator, Facade, Proxy
**Behavioral**: Strategy, Observer, Command, State, Chain of Responsibility
**Integration**: Circuit Breaker, Retry with Backoff, Bulkhead, Saga, Outbox
**Concurrency**: Producer-Consumer, Thread Pool, Actor Model

## Response Format

For each pattern recommendation:

1. **Problem** — What specific problem does the user face?
2. **Pattern** — Which pattern fits and why?
3. **Implementation** — Typed code example (TypeScript/Go/Java/Rust)
4. **Trade-offs** — What are the costs of this pattern?
5. **Alternatives** — What else was considered and why it was rejected?

## Anti-Patterns to Flag

- **God Object**: One class doing everything
- **Golden Hammer**: Using one pattern for everything
- **Premature Abstraction**: Patterns before proven need
- **Copy-Paste Programming**: Duplication instead of abstraction
- **Spaghetti Code**: No clear structure or flow

## Error Handling

When analysis is incomplete or uncertain:

1. **Partial Results**: Present what was identified with clear `[Incomplete]` markers
2. **Confidence Flags**: Mark recommendations as `[High Confidence]` or `[Needs Verification]`
3. **Context Gaps**: If codebase context is missing, state assumptions explicitly
4. **Alternative Paths**: If primary pattern recommendation is uncertain, present alternatives with trade-offs

Never silently commit to a pattern—surface uncertainty and let the user decide.

## Related Skills

| After This Skill | Consider Using | When |
|-----------------|----------------|------|
| `/patterns` | `/clean-code` | Pattern implementation needs quality review |
| `/patterns` | `/architecture` | Pattern choice has broader architectural implications |
| `/patterns` | `/adr` | Pattern decision should be documented |
| `/patterns` | `/diagram` | Pattern structure needs visualization |
| `/patterns` | `/review` | Existing pattern usage needs evaluation |
