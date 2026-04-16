# Skill Design Best Practices

## Context Window Principles

Skills consume context tokens. The system budget is ~2% of the context window (~16,000 chars as a practical fallback). Override with the `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable if skills need more room.

## CSO Principle: Description as Trigger, Not Summary

The `description` field in skill frontmatter serves as the **Context-Sensitive Orchestration (CSO)** trigger — it tells Claude _when_ to invoke the skill, not _what_ the skill does.

**Rule:** Descriptions must contain ONLY trigger conditions (user phrases, keywords, situations). Never include workflow summaries, process steps, or capability lists.

**Good** (trigger conditions only):
```yaml
description: Use when the user asks to "debug this", "fix this bug", "why is this failing", "trace this error", has a failing test, or encounters unexpected behavior.
```

**Bad** (workflow summary):
```yaml
description: Systematically diagnose bugs using reproduce-isolate-hypothesize-fix-verify methodology with built-in guards against analysis paralysis.
```

**Why this matters:** Auto-invocable skill descriptions are loaded into every conversation. Trigger-only descriptions keep the context budget lean and improve routing accuracy. Workflow summaries waste tokens and confuse the routing heuristic — they describe _what_ the skill does (which belongs in the skill body) rather than _when_ to use it.

**Audit check:** Read each description and ask: "Does this tell me WHEN to use the skill, or WHAT the skill does?" If the answer is "what", rewrite it.

## Degrees of Freedom

Match constraint level to task variability:

### High Freedom (Creative Tasks)

- Provide principles, not templates
- Use examples to illustrate range of acceptable outputs

### Medium Freedom (Structured Tasks)

- Provide flexible templates with optional sections
- Define required elements, allow variation in presentation

### Low Freedom (Mechanical Tasks)

- Provide strict templates with placeholders
- Specify exact format, validate output structure

## Quality Checklist

Before finalizing a skill:

- [ ] **Discoverable**: Description contains natural trigger phrases
- [ ] **Efficient**: No unnecessary context loading
- [ ] **Graceful**: Handles missing inputs and edge cases
- [ ] **Connected**: Links to related skills where appropriate

## Dynamic Context Injection

Use `!<command>` to inject shell output before skill content is sent to Claude. Example: `` Current branch: !`git rev-parse --abbrev-ref HEAD` `` resolves to `Current branch: feature/auth-flow` at runtime.

## Testing Strategy

**A/B Iteration Pattern**:
1. Work with Claude A (expert) to refine the skill
2. Test with Claude B (fresh instance with skill loaded) on real tasks
3. Observe Claude B's behavior and bring insights back to Claude A
4. Iterate: refine → test → observe → repeat

## Extended Thinking

Include the keyword **"ultrathink"** in skill content to activate extended thinking mode. Use for complex analysis, architecture decisions, or security audits where reasoning depth meaningfully improves results. Tradeoff: higher latency and token usage.

## Visual Output Generation

Skills can generate visual output (HTML pages, diagrams, reports) by bundling scripts in their directory and executing them during the skill process.

**Pattern**:
```markdown
## Process

### 3. Generate Visual Report

Run the bundled visualization script:

\`\`\`bash
${CLAUDE_SKILL_DIR}/scripts/generate-report.sh $ARGUMENTS
\`\`\`

The script generates an HTML file and opens it in the default browser.
```

**Best practices**:
- Bundle scripts in the skill's `scripts/` directory
- Use `allowed-tools: Bash` to permit script execution
- Generate self-contained HTML (inline CSS/JS) for portability
- Output to a temp directory or the project's build directory

## Skill Location Hierarchy

**When to use each level**:
- **Personal skills** (`~/.claude/skills/`): Role-specific workflows across all your projects. Available only to you.
- **Project skills** (`.claude/skills/`): Team-shareable, committed to the repo.

