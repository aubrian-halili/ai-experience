---
name: architecture
description: Use when the user asks "how should I design", "what's the best architecture", "how do I scale", "document this decision", "create an ADR", mentions "system design", "scaling", "microservices vs monolith", "architecture decision record", or needs help with technical decisions, infrastructure planning, or documenting architectural choices.
argument-hint: "[topic to design] or [--adr decision title]"
allowed-tools: Read, Grep, Glob, Write, Edit
---

**Existing ADRs:**
!`ls docs/architecture/decisions/adr-*.md 2>/dev/null || echo "No ADRs found"`

Provide expert guidance on system architecture decisions, design approaches, and technical strategy. Generates Architecture Decision Records (ADRs) when requested.

## Architecture Philosophy

- **NFRs First** — Clarify Non-Functional Requirements before suggesting solutions
- **Trade-off Analysis** — Every recommendation includes explicit Pros/Cons — never present one option as obviously correct
- **Start Simple** — Recommend the simplest working solution, then discuss evolution paths
- **Pragmatic Balance** — Balance architectural purity with delivery pragmatism. Acknowledge YAGNI when appropriate
- **ADR-Driven** — Structure significant decisions as Architecture Decision Records

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

Classify `$ARGUMENTS` to determine the appropriate workflow:

| Type | Indicators | Approach |
|------|-----------|----------|
| **Greenfield** | "new system", "from scratch", "build new" | Full process (steps 1–5); emphasis on requirements (step 3) |
| **Evolution** | "add feature", "extend", "enhance" | Steps 1–5; emphasis on existing patterns (step 2) and incremental design (step 4) |
| **Migration** | "move to", "replace", "upgrade" | Steps 1–5; emphasis on risk assessment and phased planning (step 4) |
| **Optimization** | "scale", "performance", "bottleneck" | Steps 1–5; emphasis on existing analysis (step 2) and targeted changes (step 4) |
| **Integration** | "connect", "integrate", "API" | Steps 1–5; emphasis on interface design and compatibility (step 4) |
| **ADR** | `--adr`, "document decision", "record choice" | ADR generation process (steps 1–2, 6–8) |

## Process

**Branch point:** Design workflow → steps 1–5. ADR workflow → steps 1, 2, 6–8.

### 1. Pre-flight

- Determine workflow from `$ARGUMENTS` and Input Classification
- Check for existing architecture docs (`docs/architecture/`, `ARCHITECTURE.md`, `docs/adr/`)
- Review existing ADRs (pre-loaded above); if none found, numbering starts at `adr-001`
- If no arguments provided, ask the user what to design or analyze

### 2. Analyze Existing Patterns

- Find similar features, document conventions, identify stack and layers
- Review existing architecture docs and ADRs for context and prior decisions

### 3. Clarify Requirements (Design only)

- Functional requirements, non-functional requirements (scalability, latency, availability), constraints
- Estimate scale — Users (DAU/MAU/peak), data (storage/growth/retention), traffic (QPS/read-write ratio/burst patterns)

### 4. Design Architecture (Design only)

ultrathink

- **Define Components** — Core services, data stores, caching, external integrations, interface definitions
- **Design Interactions** — Sync vs async, API contracts, error handling and retry strategies
- **Address Cross-Cutting Concerns** — Auth/authz, logging/monitoring/alerting, security/compliance

### 5. Present Blueprint (Design only)

- Map components to files, define build sequence, specify verification
- See `@references/response-templates.md` for detailed output structure

### 6. ADR: Gather Decision Context (ADR only)

- See `@references/adr-guidelines.md` for when to write ADRs and status definitions
- Ask for decision context if not provided in `$ARGUMENTS`
- Identify decision drivers (what forces are at play?)
- List 2–3 considered options with Pros/Cons
- Recommend a decision with clear rationale
- Document consequences (positive, negative, risks)
- See `@references/response-templates.md` for ADR format

### 7. ADR: Confirm Before Writing (ADR only)

**Present the complete ADR to the user before writing to disk.**

- Show proposed file path: `docs/architecture/decisions/adr-NNN-title.md`
- Show full ADR content
- Ask the user to review and confirm before proceeding
- If changes requested, revise and present again

### 8. ADR: Write and Verify (ADR only)

**Only proceed after user approval.**

- Create the ADR directory if it doesn't exist
- Write ADR file to `docs/architecture/decisions/adr-NNN-title.md`
- Verify the file was created by reading it back with Read or listing the directory with Glob
- Show the file path and confirm success

## Architecture Patterns

| Pattern | Best For | Key Trade-off |
|---------|----------|---------------|
| Monolithic | Small teams, simple domains, rapid prototyping | Simple deployment vs limited scalability |
| Microservices | Large teams, complex domains, independent scaling | Flexibility vs operational complexity |
| Event-Driven | Async workflows, audit trails, temporal decoupling | Loose coupling vs eventual consistency |
| Serverless | Variable workloads, cost optimization | Reduced ops burden vs vendor lock-in |

## Output Principles

- **Trade-off transparency** — always present pros/cons for each option; never present a single approach as obviously correct without acknowledging alternatives
- **Diagram-first** — include mermaid diagrams showing component relationships and data flow; visual clarity precedes detailed text
- **Actionable blueprints** — map every recommendation to concrete files, build sequence, and verification steps; designs should be immediately implementable
- **Confidence signaling** — explicitly mark recommendations as `[High Confidence]` or `[Needs Verification]`; surface assumptions and knowledge gaps

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Ask what to design or analyze |
| `[topic]` | Architecture design for the given topic |
| `--adr [title]` | Generate ADR with the given decision title |
| `--adr` (no title) | Ask for decision title, then generate ADR |

## Error Handling

| Scenario | Response |
|----------|----------|
| Incomplete analysis | Present partial results with `[Incomplete]` markers |
| Uncertain recommendation | Mark as `[High Confidence]` or `[Needs Verification]` |
| Missing information | Explicitly list assumptions that could invalidate design |
| Codebase exploration fails | Proceed with stated assumptions, document fallback strategy |
| Partial ADR | Create with `[TBD]` markers and `Proposed` status, list questions |
| ADR directory missing | Create `docs/architecture/decisions/` directory, then write |
| Existing ADR with same number | Increment the number; check existing files first |
| No existing ADRs found | Start numbering at `adr-001` |

Never silently skip sections—surface gaps and limitations explicitly.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/patterns` | Need specific pattern implementation |
| `/diagram` | Visual representation would clarify |
| `/review` | Existing code needs evaluation |
| `/explore` | Need to understand existing system first |
| `/docs` | Need detailed documentation beyond ADR |
