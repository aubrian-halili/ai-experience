---
name: patterns
description: Design pattern recommendations and implementation examples. Use when the user needs help choosing or implementing design patterns.
argument-hint: "[problem or pattern name]"
---

Provide guidance on selecting and implementing design patterns for specific problems.

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
