---
name: architecture
description: System design and architecture guidance. Use when the user needs help with architecture decisions, scaling strategies, or system design.
argument-hint: "[topic or system to design]"
---

Provide expert guidance on system architecture decisions, design approaches, and technical strategy.

## Process

1. **Clarify Requirements**
   - Functional requirements (what the system does)
   - Non-functional requirements (scalability, latency, availability)
   - Constraints (budget, timeline, team skills, existing systems)

2. **Estimate Scale**
   - Users: DAU, MAU, peak concurrent
   - Data: Storage size, growth rate, retention
   - Traffic: QPS, read/write ratio, burst patterns

3. **Define Components**
   - Core services and their responsibilities
   - Data stores and caching layers
   - External integrations and APIs

4. **Design Interactions**
   - Synchronous vs asynchronous communication
   - API contracts and protocols
   - Error handling and retry strategies

5. **Address Cross-Cutting Concerns**
   - Authentication and authorization
   - Logging, monitoring, alerting
   - Security and compliance

## Architecture Patterns

| Pattern | Best For | Key Trade-off |
|---------|----------|---------------|
| Monolithic | Small teams, simple domains, rapid prototyping | Simple deployment vs limited scalability |
| Microservices | Large teams, complex domains, independent scaling | Flexibility vs operational complexity |
| Event-Driven | Async workflows, audit trails, temporal decoupling | Loose coupling vs eventual consistency |
| Serverless | Variable workloads, cost optimization | Reduced ops burden vs vendor lock-in |

## Response Format

```markdown
## Architecture Recommendation

### Context
[Understanding of requirements and constraints]

### Proposed Architecture
[High-level description with mermaid diagram]

### Key Components
| Component | Responsibility | Technology Options |
|-----------|---------------|-------------------|

### Trade-offs
| Decision | Pros | Cons |
|----------|------|------|

### Risks & Mitigations
- Risk: [Description] → Mitigation: [Approach]

### Next Steps
1. [Immediate action]
2. [Follow-up action]
```
