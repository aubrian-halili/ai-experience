---
name: clean-code
description: Use when the user asks to "clean up this code", "refactor this", "improve code quality", mentions "SOLID principles", "code smells", "technical debt", or wants refactoring suggestions and maintainability improvements.
argument-hint: "[file or component to review]"
allowed-tools: Read, Grep, Glob
---

Provide code quality analysis, refactoring suggestions, and clean code guidance.

## Review Philosophy

- **Precision over completeness** — zero false positives matters more than exhaustive coverage
- **Confidence gate** — internally score each finding 0-100; only report findings with confidence >= 80
- If uncertain about a finding, leave it out rather than risk noise

## When to Use

### This Skill Is For

- Code quality analysis and refactoring suggestions
- SOLID principle violation detection
- Code smell identification with refactoring strategies

### Use a Different Approach When

- Reviewing for correctness, security, or performance → use `/review`
- Implementing specific design patterns → use `/patterns`
- Addressing structural/architectural issues → use `/architecture`

## Process

### 1. Pre-flight

Determine analysis scope from `$ARGUMENTS`:

| Input | Scope |
|-------|-------|
| File path (e.g., `src/auth/login.ts`) | Analyze the single file |
| Directory (e.g., `src/auth/`) | Analyze files in the directory, prioritize by complexity |
| Component name (e.g., `LoginService`) | Search for the component by name, analyze matching files |
| Line range (e.g., `src/auth/login.ts:50-100`) | Focus analysis on the specified line range |
| (none) | Ask user to specify a file or component |

**Stop conditions:**
- Target file or component not found → report and stop
- Target is unreadable or binary → report and stop
- Scope is overly broad (e.g., entire repo root) → ask user to narrow scope

### 2. Analyze

Read target code and evaluate against these 6 analysis dimensions:

- **Naming** — Clear, intention-revealing names
- **Error handling** — Fail fast, meaningful errors, no swallowed exceptions
- **Magic values** — No magic numbers or strings; constants or enums used instead
- **Test coverage** — Tests cover behavior, not just lines
- **Dead code** — No commented-out code, no unreachable branches
- **Security** — Security considerations addressed (input validation, data exposure)

For each dimension, cross-reference the SOLID Checks and Code Smells tables below to identify specific violations. Apply the confidence gate from Review Philosophy — only flag findings scored >= 80 confidence internally.

### 3. Report Findings

For each finding, provide:

- **Priority**: High | Medium | Low
- **Location**: `file:line`
- **Issue**: What's wrong and which principle it violates
- **Impact**: Why it matters
- **Fix**: Concrete refactoring with diff example

Group findings by priority (High first, then Medium, then Low).

**No findings case:** If analysis completes with no findings above the confidence threshold, explicitly state: "No findings above confidence threshold. Code meets clean code standards for the dimensions analyzed."

### 4. Verify Completeness

- Confirm which of the 6 analysis dimensions were evaluated
- Note any dimensions that could not be evaluated (e.g., no tests exist to assess test coverage)
- If findings suggest deeper structural or architectural issues, recommend `/architecture` or `/review` for further analysis

## SOLID Checks

| Principle | Violation Signal | Fix |
|-----------|-----------------|-----|
| **SRP** | Class has multiple reasons to change | Extract classes by responsibility |
| **OCP** | Modifying existing code for new types | Use polymorphism or strategy |
| **LSP** | Subclass breaks parent's contract | Redesign hierarchy |
| **ISP** | Client depends on methods it doesn't use | Split into focused interfaces |
| **DIP** | High-level module depends on concrete class | Inject abstractions |

## Code Smells to Detect

| Smell | Refactoring |
|-------|-------------|
| Long Method (> 20 lines) | Extract Method |
| Large Class | Extract Class |
| Feature Envy | Move Method |
| Data Clumps | Extract Class / Parameter Object |
| Primitive Obsession | Value Objects |
| Switch Statements | Polymorphism |
| Speculative Generality | Remove unused abstraction |
| Duplicate Code | Extract Method/Class |

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Ask user to specify a file or component |
| `src/auth/login.ts` | Analyze the specified file |
| `src/auth/` | Analyze files in the directory, prioritize by complexity |
| `LoginService` | Search for the component by name, analyze matching files |
| `src/auth/login.ts:50-100` | Focus analysis on the specified line range |

## Error Handling

| Scenario | Response |
|----------|----------|
| File not found | Report the missing file and ask user to verify the path |
| Scope too broad | Ask user to narrow scope to a specific file or directory |
| No findings | Explicitly state no findings above confidence threshold (>= 80) |
| Partial analysis | Present findings with `[Incomplete]` markers |
| Uncertain finding | Below confidence gate (< 80) — omit from report, note in Verify Completeness |
| Scope limited | Explicitly state what was NOT analyzed and why |
| File access fails | Suggest alternative investigation approaches |

Never silently omit findings—surface limitations explicitly.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Need correctness, security, or performance review |
| `/patterns` | Refactoring would benefit from design patterns |
| `/architecture` | Structural issues suggest architectural problems |
| `/architecture --adr` | Refactoring decision should be documented |
