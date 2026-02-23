---
name: diagram
description: Use when the user asks to "draw a diagram", "visualize this system", "create a flowchart", "show the architecture", mentions "ERD", "sequence diagram", "state machine", or needs visual representations of systems and flows.
argument-hint: "[system or flow to diagram]"
allowed-tools: Read, Grep, Glob
---

Generate architecture diagrams using Mermaid syntax based on the user's description or codebase.

## Guidelines

1. **One diagram, one purpose** — don't overload a single diagram
2. **Label relationships** — show what flows between components
3. **Include a legend** when using custom notation
4. **Use consistent notation** throughout
5. **Start with the highest useful abstraction level** — zoom in only if asked

## When to Use

### This Skill Is For

- Visualizing system architecture and component interactions
- Creating flowcharts for process workflows
- Generating data models (ERD) and class diagrams

### Use a Different Approach When

- Understanding system first → use `/explore`
- Designing architecture → use `/architecture`
- Need implementation details beyond visualization → use `/patterns`

## Diagram Selection

| Need | Diagram Type |
|------|--------------|
| High-level system overview | C4 Context |
| Technical architecture | C4 Container |
| Component interactions | C4 Component |
| API call flows | Sequence |
| Process workflows | Flowchart |
| Data models | ERD |
| Object design | Class |
| Lifecycle states | State |

## Process

### 1. Pre-flight

- Parse `$ARGUMENTS` to determine what to visualize
- If analyzing existing code, verify target files are accessible via Glob/Read
- If from a description, check if enough detail is provided to proceed
- Classify the request using the Diagram Selection table above

**Stop conditions:**
- Target file or directory not found → report and stop
- Description too vague to select a diagram type → ask user to clarify
- Scope is ambiguous (e.g., "diagram everything") → ask user to narrow focus

### 2. Generate

- Read source code if diagramming an existing system
- Select diagram type from the Diagram Selection table
- Build the Mermaid diagram following Guidelines
- Use the Mermaid Reference section for correct syntax

### 3. Present

- Output the `mermaid` code block
- Explain key relationships and components shown
- Include a legend when using custom notation

### 4. Verify and Extend

- Confirm the diagram covers the requested scope
- Note any components omitted or marked incomplete
- Offer to zoom into specific areas or generate complementary diagrams
- Suggest related skills if deeper analysis is needed

## Mermaid Reference

**C4 Context**: `C4Context` — system with users and external dependencies
**C4 Container**: `C4Container` — high-level technical components inside the system
**Sequence**: `sequenceDiagram` — interactions over time between participants
**Flowchart**: `flowchart TD/LR` — process flows and decision points
**ERD**: `erDiagram` — data model relationships
**Class**: `classDiagram` — object-oriented structure
**State**: `stateDiagram-v2` — state transitions and lifecycle

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Ask user what to visualize |
| Topic or concept (e.g., `auth flow`) | Generate diagram based on the description |
| File path (e.g., `src/auth/login.ts`) | Read the file and diagram its structure |
| Directory (e.g., `src/auth/`) | Read files in the directory and diagram the module |
| Component name (e.g., `LoginService`) | Search for the component, diagram its interactions |

## Error Handling

| Scenario | Response |
|----------|----------|
| Incomplete information | Generate what's known with `[Incomplete]` markers |
| Uncertain components | Add `[Needs Verification]` notes to diagram sections |
| Scope limited | Explicitly state what was NOT included and why |
| Unknown components | Use dashed lines or `???` labels for placeholders |
| Target not found | Report the missing file or component and ask user to verify the path |
| Scope too broad | Ask user to narrow scope to a specific module or flow |
| Diagram too complex | Split into multiple focused diagrams, one per concern |

Example for incomplete information:
```mermaid
flowchart TD
    A[Known Component] --> B[Known Component]
    B -.-> C["??? Unknown Handler"]
    style C fill:#ffcccc
```

Never silently omit components—surface gaps visually.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/explore` | Need to understand components before visualizing |
| `/architecture` | Diagram reveals architectural improvements |
| `/architecture --adr` | Diagram documents an important decision |
| `/patterns` | Diagram shows pattern implementation |
