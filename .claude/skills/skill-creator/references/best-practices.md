# Skill Design Best Practices

## Context Window Principles

Skills consume context tokens. Optimize by:

1. **Front-load essentials** — Put critical instructions in SKILL.md directly
2. **Defer details** — Use `@references/` for supplementary guidance
3. **Avoid redundancy** — Don't repeat what's in project CLAUDE.md
4. **Trim examples** — One good example beats three mediocre ones

## Degrees of Freedom

Match constraint level to task variability:

### High Freedom (Creative Tasks)

- Provide principles, not templates
- Use examples to illustrate range of acceptable outputs
- Example: Architecture design, brainstorming

### Medium Freedom (Structured Tasks)

- Provide flexible templates with optional sections
- Define required elements, allow variation in presentation
- Example: Code reviews, documentation

### Low Freedom (Mechanical Tasks)

- Provide strict templates with placeholders
- Specify exact format, validate output structure
- Example: Changelog entries, commit messages

## Output Pattern Selection

### Use Templates When

- Output format is consistent across invocations
- Users expect predictable structure
- Compliance or standards require specific format

### Use Examples When

- Output varies significantly by input
- Creativity or judgment drives output quality
- Multiple valid approaches exist

## Workflow Patterns

### Sequential Workflow

Steps execute in order. Each step depends on previous.

```
1. Gather context
2. Analyze
3. Generate
4. Validate
```

Best for: Linear tasks with clear dependencies.

### Conditional Workflow

Steps branch based on conditions.

```
1. Assess input type
2. IF type A → Process A
   IF type B → Process B
3. Merge results
```

Best for: Tasks with meaningful variation in execution path.

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Kitchen sink | Too many responsibilities | Split into focused skills |
| Echo chamber | Repeats CLAUDE.md | Reference don't repeat |
| Template prison | Over-constrains output | Add degrees of freedom |
| Missing triggers | Hard to discover/invoke | Add clear trigger phrases |
| Silent failure | No guidance on errors | Add error handling section |

## Quality Checklist

Before finalizing a skill:

- [ ] **Discoverable**: Description contains natural trigger phrases
- [ ] **Scoped**: Single, clear responsibility
- [ ] **Efficient**: No unnecessary context loading
- [ ] **Guided**: Clear step-by-step process
- [ ] **Graceful**: Handles missing inputs and edge cases
- [ ] **Connected**: Links to related skills where appropriate
- [ ] **Tested**: Verified with real invocations
