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

## Review Checklist

- [ ] Clear, intention-revealing names
- [ ] Functions do one thing (< 20 lines ideal)
- [ ] No deep nesting (max 2-3 levels)
- [ ] Proper error handling (fail fast, meaningful errors)
- [ ] No magic numbers/strings
- [ ] DRY — no duplication
- [ ] SOLID principles followed
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

## Project Structure Compliance

Validate against CLAUDE.md's defined layer structure:
- **Domain** (`src/domain/`) must not import from infrastructure or presentation
- **Infrastructure** (`src/infrastructure/`) must not contain business logic
- **Presentation** (`src/presentation/`) must not bypass application layer to reach domain directly
- Flag any cross-layer violations as findings

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

For each finding, provide:
- **Priority**: High | Medium | Low
- **Location**: `file:line`
- **Issue**: What's wrong and which principle it violates
- **Impact**: Why it matters
- **Fix**: Concrete refactoring with diff example

## Evaluation Gate

Before finalizing the analysis, internally assess:

| Criterion | Status | Notes |
|-----------|--------|-------|
| All SOLID violations identified? | PASS/NEEDS_IMPROVEMENT/FAIL | |
| Code smells catalogued? | PASS/NEEDS_IMPROVEMENT/FAIL | |
| Refactoring suggestions actionable? | PASS/FAIL | |
| Layer violations checked? | PASS/FAIL | |

**Overall**: PASS | NEEDS_IMPROVEMENT | FAIL

- If **FAIL** → must provide specific guidance for each failing criterion
- Only report findings with confidence >= 80

## Iteration Protocol

For complex refactoring analysis:

1. **Initial Pass**: Identify all code smells and violations
2. **Self-Evaluation**: Score each finding (0-100 confidence)
3. **Refinement**: For findings scoring 60-79, gather additional context before discarding
4. **Prioritization**: Rank findings by impact and effort
5. **Final Report**: Present validated findings with clear refactoring path

If user requests deeper analysis, expand scope to include:
- Indirect dependencies
- Test coverage gaps
- Historical patterns (git blame for repeated issues)

## Error Handling

When analysis is incomplete or uncertain:

1. **Partial Results**: Present what was found with clear `[Incomplete]` markers
2. **Confidence Flags**: Mark findings as `[High Confidence]` or `[Needs Verification]`
3. **Scope Limitations**: Explicitly state what was NOT analyzed and why
4. **Fallback Strategy**: If file access fails, suggest alternative investigation approaches

Never silently omit findings—surface limitations explicitly.

---

## Related Skills

| After This Skill | Consider Using | When |
|-----------------|----------------|------|
| `/clean-code` | `/review` | Need correctness, security, or performance review |
| `/clean-code` | `/patterns` | Refactoring would benefit from design patterns |
| `/clean-code` | `/architecture` | Structural issues suggest architectural problems |
| `/clean-code` | `/adr` | Refactoring decision should be documented |

> For correctness, security, and performance review, use `/review` first.
