---
name: architecture
description: Use when the user asks "how should I design", "what's the best architecture", "how do I scale", mentions "system design", "scaling", "microservices vs monolith", or needs help with technical decisions and infrastructure planning.
argument-hint: "[topic or system to design]"
---

Provide expert guidance on system architecture decisions, design approaches, and technical strategy. Deliver actionable architecture blueprints that bridge design to implementation.

## Input Classification

First, classify the request to determine the appropriate approach:

| Type | Indicators | Approach |
|------|-----------|----------|
| **Greenfield** | "new system", "from scratch", "build new" | Full architecture process (all steps) |
| **Evolution** | "add feature", "extend", "enhance" | Pattern analysis + incremental design |
| **Migration** | "move to", "replace", "upgrade", "refactor" | Risk assessment + phased migration plan |
| **Optimization** | "scale", "performance", "bottleneck" | Bottleneck analysis + targeted changes |
| **Integration** | "connect", "integrate", "API" | Interface design + compatibility analysis |

Select the approach before proceeding—this determines which process steps to emphasize.

## Process

1. **Analyze Existing Patterns**
   - Find similar features or modules in codebase
   - Document established conventions (naming, structure, patterns)
   - Identify technology stack and abstraction layers
   - Note relevant CLAUDE.md guidelines

2. **Clarify Requirements**
   - Functional requirements (what the system does)
   - Non-functional requirements (scalability, latency, availability)
   - Constraints (budget, timeline, team skills, existing systems)

3. **Estimate Scale**
   - Users: DAU, MAU, peak concurrent
   - Data: Storage size, growth rate, retention
   - Traffic: QPS, read/write ratio, burst patterns

4. **Define Components**
   - Core services and their responsibilities
   - Data stores and caching layers
   - External integrations and APIs
   - Interface definitions and contracts

5. **Design Interactions**
   - Synchronous vs asynchronous communication
   - API contracts and protocols
   - Error handling and retry strategies

6. **Address Cross-Cutting Concerns**
   - Authentication and authorization
   - Logging, monitoring, alerting
   - Security and compliance

7. **Create Implementation Blueprint**
   - Map components to specific files
   - Define build sequence with dependencies
   - Specify verification approach

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

### Existing Patterns Analysis
[Summary of codebase conventions, relevant existing implementations, and patterns to follow]

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

### Implementation Blueprint

#### Files to Create
| File | Purpose | Dependencies |
|------|---------|--------------|
| `src/domain/[entity].ts` | [What it defines] | None |
| `src/application/[service].ts` | [What it does] | `[entity].ts` |

#### Files to Modify
| File | Change | Reason |
|------|--------|--------|
| `src/infrastructure/[existing].ts` | [What changes] | [Why needed] |

#### Component Interfaces
[TypeScript interface definitions for key components]

### Build Sequence

- [ ] **Phase 1: Domain Layer**
  - [ ] Create entity types
  - [ ] Define value objects
  - [ ] Verify: Unit tests pass

- [ ] **Phase 2: Application Layer**
  - [ ] Implement service interfaces
  - [ ] Create DTOs
  - [ ] Verify: Integration tests pass

- [ ] **Phase 3: Infrastructure Layer**
  - [ ] Implement repositories
  - [ ] Configure external services
  - [ ] Verify: E2E tests pass

### Critical Details Checklist

- [ ] Error handling strategy defined
- [ ] State management approach chosen
- [ ] Testing strategy covers pyramid
- [ ] Performance considerations addressed
- [ ] Security requirements met

### Next Steps
1. [Immediate action]
2. [Follow-up action]
```

## Error Handling

When analysis is incomplete or uncertain:

1. **Partial Results**: Present what was designed with clear `[Incomplete]` markers
2. **Confidence Flags**: Mark recommendations as `[High Confidence]` or `[Needs Verification]`
3. **Assumption Documentation**: Explicitly list assumptions that could invalidate the design
4. **Fallback Strategy**: If codebase exploration fails, proceed with stated assumptions and flag for validation

Never silently skip sections—surface gaps and limitations explicitly.

## Related Skills

| After This Skill | Consider Using | When |
|-----------------|----------------|------|
| `/architecture` | `/patterns` | Need specific pattern implementation guidance |
| `/architecture` | `/diagram` | Visual representation would clarify the design |
| `/architecture` | `/adr` | Architectural decision should be formally documented |
| `/architecture` | `/review` | Existing code needs evaluation against new architecture |
| `/architecture` | `/explore` | Need to understand existing system before designing |
