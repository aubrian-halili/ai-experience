---
name: explore
description: Use when the user asks "how does X work", "explain this feature", "trace this flow", "what does this module do", wants to understand existing code end-to-end, or needs deep codebase investigation.
argument-hint: "[feature, module, or flow to investigate]"
context: fork
agent: Explore
---

Systematically explore and explain how existing functionality works in the codebase.

## Process

### 1. Scope

- Identify the investigation target from `$ARGUMENTS`
- If broad, ask which aspect to focus on first
- Determine depth: Surface (quick orientation) | Standard (full flow) | Deep (internals + edge cases)

### 2. Discover

**Entry Points** — Locate route handlers, event listeners, CLI commands, or exported functions that trigger the flow
**Dependencies** — Trace imports outward; map internal modules and external services
**Data Flow** — Follow data from input to output through all transformations, validations, and serialization boundaries
**Control Flow** — Map execution path including branching, error handling, middleware, and async operations

### 3. Analyze

- Design patterns in use and why
- Architectural layer mapping (domain, application, infrastructure)
- Error handling and recovery strategy
- State management and side effects
- Configuration that alters behavior (env vars, feature flags)
- Performance considerations (bottlenecks, caching, async patterns)

### 4. Document

Present findings using the response format below.

## Response Format

```markdown
## Exploration: [Feature/Functionality Name]

### Overview
[1-3 sentence summary]

### Entry Points
| Entry Point | Type | Location |
|-------------|------|----------|
| [Name] | [HTTP / Event / CLI / Cron] | `file:line` |

### Execution Flow
1. **[Step]** — `file:line`
   - [What happens and why]

### Key Components
| Component | Responsibility | Location |
|-----------|---------------|----------|
| [Name] | [What it does] | `file:line` |

### Data Flow
[ASCII or mermaid diagram showing transformations and side effects]

### Dependencies
- **Internal**: `[Module]` — [purpose] (`file:line`)
- **External**: `[Library/Service]` — [purpose]

### Error Handling
| Scenario | Strategy | Location |
|----------|----------|----------|
| [Case] | [What happens] | `file:line` |

### Design Patterns Observed
- **[Pattern]** — [where and why] (`file:line`)

### Performance Considerations
- [Bottlenecks, caching strategies, async patterns, query optimization]

### Essential Files
| File | Purpose |
|------|---------|
| `path/to/file` | [Why this file is critical to understand the feature] |

### Observations
- [Tech debt, implicit assumptions, undocumented edge cases]
```

## Exploration Strategies

**Single Function**: Read signature → trace body → resolve called functions → check callers for context
**API Endpoint**: Route definition → middleware chain → handler → service logic → DB/external calls → response
**Feature Flow**: UI trigger → API → service → data layer → async operations → event subscribers
**Module**: Public API (exports) → internal structure → core abstractions → external consumer patterns
