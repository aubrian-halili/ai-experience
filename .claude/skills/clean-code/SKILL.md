---
name: clean-code
description: Use when the user asks to "clean up this code", "refactor this", "improve code quality", mentions "SOLID principles", "code smells", "technical debt", or wants refactoring suggestions and maintainability improvements.
argument-hint: "[file or component to review]"
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

## Review Checklist

- [ ] Clear, intention-revealing names
- [ ] Proper error handling (fail fast, meaningful errors)
- [ ] No magic numbers/strings
- [ ] Tests cover behavior
- [ ] No commented-out code
- [ ] Security considerations addressed

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

## Response Format

Use `$ARGUMENTS` if provided (file or component to analyze).

For each finding, provide:
- **Priority**: High | Medium | Low
- **Location**: `file:line`
- **Issue**: What's wrong and which principle it violates
- **Impact**: Why it matters
- **Fix**: Concrete refactoring with diff example

## Error Handling

| Scenario | Response |
|----------|----------|
| Partial analysis | Present findings with `[Incomplete]` markers |
| Uncertain finding | Mark as `[High Confidence]` or `[Needs Verification]` |
| Scope limited | Explicitly state what was NOT analyzed and why |
| File access fails | Suggest alternative investigation approaches |

Never silently omit findings—surface limitations explicitly.

## Related Skills

| After This Skill | Consider Using | When |
|-----------------|----------------|------|
| `/clean-code` | `/review` | Need correctness, security, or performance review |
| `/clean-code` | `/patterns` | Refactoring would benefit from design patterns |
| `/clean-code` | `/architecture` | Structural issues suggest architectural problems |
| `/clean-code` | `/architecture --adr` | Refactoring decision should be documented |

> For correctness, security, and performance review, use `/review` first.
