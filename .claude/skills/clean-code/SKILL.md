---
name: clean-code
description: Code quality review, SOLID analysis, and refactoring suggestions. Use when the user wants code quality improvements or refactoring help.
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

---

> For correctness, security, and performance review, use `/review` first.
