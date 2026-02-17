---
name: architecture
description: Use when the user asks "how should I design", "what's the best architecture", "how do I scale", "document this decision", "create an ADR", mentions "system design", "scaling", "microservices vs monolith", "architecture decision record", or needs help with technical decisions, infrastructure planning, or documenting architectural choices.
argument-hint: "[topic to design] or [--adr decision title]"
---

Provide expert guidance on system architecture decisions, design approaches, and technical strategy. Optionally generate Architecture Decision Records (ADRs) to document significant choices.

## Core Behaviors

- **NFRs First**: Clarify Non-Functional Requirements before suggesting solutions
- **Trade-off Analysis**: Every recommendation includes explicit Pros/Cons — never present one option as obviously correct
- **Start Simple**: Recommend the simplest working solution, then discuss evolution paths
- **Pragmatic Balance**: Balance architectural purity with delivery pragmatism. Acknowledge YAGNI when appropriate
- **ADR-Driven**: Structure significant decisions as Architecture Decision Records

## When to Use

### This Skill Is For

- Designing new systems or major features
- Evaluating architectural alternatives with trade-offs
- Creating Architecture Decision Records (ADRs)
- Scaling and performance optimization strategies

### Use a Different Approach When

- Implementing specific design patterns → use `/patterns`
- Reviewing existing code quality → use `/review`
- Understanding current system first → use `/explore`
- Creating visual diagrams only → use `/diagram`

## Input Classification

First, classify the request to determine the appropriate approach:

| Type | Indicators | Approach |
|------|-----------|----------|
| **Greenfield** | "new system", "from scratch", "build new" | Full architecture process |
| **Evolution** | "add feature", "extend", "enhance" | Pattern analysis + incremental design |
| **Migration** | "move to", "replace", "upgrade" | Risk assessment + phased plan |
| **Optimization** | "scale", "performance", "bottleneck" | Bottleneck analysis + targeted changes |
| **Integration** | "connect", "integrate", "API" | Interface design + compatibility |
| **ADR** | "--adr", "document decision", "record choice" | Architecture Decision Record |

## Process

### For Architecture Design

Use `$ARGUMENTS` if provided (topic or system to design).

1. **Analyze Existing Patterns** — Find similar features, document conventions, identify stack and layers
2. **Clarify Requirements** — Functional requirements, non-functional requirements (scalability, latency, availability), constraints
3. **Estimate Scale** — Users (DAU/MAU/peak), data (storage/growth/retention), traffic (QPS/read-write ratio/burst patterns)
4. **Define Components** — Core services, data stores, caching, external integrations, interface definitions
5. **Design Interactions** — Sync vs async, API contracts, error handling and retry strategies
6. **Address Cross-Cutting Concerns** — Auth/authz, logging/monitoring/alerting, security/compliance
7. **Create Implementation Blueprint** — Map components to files, define build sequence, specify verification

See `@references/response-templates.md` for detailed output structure.

### For ADR Generation

Use `$ARGUMENTS` with `--adr` flag or decision title.

1. Ask for decision context if not provided
2. Identify decision drivers (what forces are at play?)
3. List 2-3 considered options with Pros/Cons
4. Recommend a decision with clear rationale
5. Document consequences (positive, negative, risks)
6. Write ADR to `docs/architecture/decisions/adr-NNN-title.md`

See `@references/response-templates.md` for ADR format.
See `@references/adr-guidelines.md` for when to write ADRs and status definitions.

## Architecture Patterns

| Pattern | Best For | Key Trade-off |
|---------|----------|---------------|
| Monolithic | Small teams, simple domains, rapid prototyping | Simple deployment vs limited scalability |
| Microservices | Large teams, complex domains, independent scaling | Flexibility vs operational complexity |
| Event-Driven | Async workflows, audit trails, temporal decoupling | Loose coupling vs eventual consistency |
| Serverless | Variable workloads, cost optimization | Reduced ops burden vs vendor lock-in |

## Error Handling

| Scenario | Response |
|----------|----------|
| Incomplete analysis | Present partial results with `[Incomplete]` markers |
| Uncertain recommendation | Mark as `[High Confidence]` or `[Needs Verification]` |
| Missing information | Explicitly list assumptions that could invalidate design |
| Codebase exploration fails | Proceed with stated assumptions, document fallback strategy |
| Partial ADR | Create with `[TBD]` markers and `Proposed` status, list questions |

Never silently skip sections—surface gaps and limitations explicitly.

## Related Skills

| After This Skill | Consider Using | When |
|-----------------|----------------|------|
| `/architecture` | `/patterns` | Need specific pattern implementation |
| `/architecture` | `/diagram` | Visual representation would clarify |
| `/architecture` | `/review` | Existing code needs evaluation |
| `/architecture` | `/explore` | Need to understand existing system first |
| `/architecture` | `/docs` | Need detailed documentation beyond ADR |
