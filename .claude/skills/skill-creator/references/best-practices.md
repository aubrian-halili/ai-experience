# Skill Design Best Practices

## Context Window Principles

Skills consume context tokens. The system budget is ~2% of the context window (~16,000 chars as a practical fallback). Override with the `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable if skills need more room. Optimize by:

1. **Description efficiency** — Descriptions are always in context for auto-invocable skills. Keep under 500 chars. Use `disable-model-invocation: true` for action skills to exclude from auto-invoke context
2. **Front-load essentials** — Put critical instructions in SKILL.md directly
3. **Defer details** — Use `@references/` for supplementary guidance
4. **Avoid redundancy** — Don't repeat what's in project CLAUDE.md
5. **Trim examples** — One good example beats three mediocre ones
6. **Manual-only for actions** — Skills that perform destructive or external actions (deploy, push, delete) should set `disable-model-invocation: true` to avoid accidental auto-invocation and to save context budget

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

## Naming Conventions

Use **gerund form** (verb + -ing) for skill names when possible:

**Recommended patterns**:
- `processing-pdfs` — gerund form (preferred)
- `pdf-processing` — noun phrase (acceptable)
- `process-pdfs` — action-oriented (acceptable)

**Avoid**:
- Vague names: `helper`, `utils`, `tools`
- Overly generic: `documents`, `data`, `files`
- Reserved words: `anthropic-helper`, `claude-tools`
- Inconsistent patterns within your skill collection

**Why this matters**: Consistent naming makes skills easier to reference, understand at a glance, and organize. The name becomes the `/slash-command`.

## Dynamic Context Injection

**String substitution variables** available in skill content:

- `$ARGUMENTS` — all arguments passed when invoking
- `$ARGUMENTS[N]` or `$N` — specific argument by index (0-based)
- `${CLAUDE_SESSION_ID}` — unique session identifier, useful for per-session logging or temp file isolation
- `${CLAUDE_SKILL_DIR}` — the skill's own directory path; use to reference bundled scripts portably instead of hardcoding `.claude/skills/<name>/`
- `!<command>` — dynamic context injection; shell command output replaces placeholder before skill content is sent to Claude

**Example use case**: Inject current git branch into skill instructions

```markdown
Current branch: !<git rev-parse --abbrev-ref HEAD>
```

Claude sees: "Current branch: feature/auth-flow" (output replaced at runtime).

## Subagent Patterns

Use `context: fork` + `agent` field to run skills in isolated subagent context (no conversation history):

```yaml
context: fork
agent: Explore
```

**When to use**:
- Deep codebase investigation where conversation history is noise
- Tasks requiring specialized agent capabilities
- Operations that should not leak into main conversation

**Available agents**: `Explore`, `Plan`, `general-purpose`, or custom agents defined in `.claude/agents/<name>.md`

**Tradeoff**: Subagent has no conversation context but focused instructions.

## Testing Strategy

**Test with multiple models**: Skills work differently across Haiku (fast/economical), Sonnet (balanced), and Opus (powerful reasoning).

- **Haiku**: Does the skill provide enough guidance?
- **Sonnet**: Is the skill clear and efficient?
- **Opus**: Does the skill avoid over-explaining?

**A/B Iteration Pattern**:
1. Work with Claude A (expert) to refine the skill
2. Test with Claude B (fresh instance with skill loaded) on real tasks
3. Observe Claude B's behavior and bring insights back to Claude A
4. Iterate: refine → test → observe → repeat

**Evaluation-driven development**:
1. Identify gaps by running Claude without the skill
2. Create 3+ evaluation scenarios
3. Establish baseline performance
4. Write minimal instructions to pass evaluations
5. Iterate based on real usage

## Extended Thinking

Skills can enable extended thinking (deeper reasoning) by including the keyword **"ultrathink"** in their content. When Claude encounters this keyword during skill execution, it activates extended thinking mode for more thorough analysis.

**When to use**: Complex analysis skills, architecture decisions, security audits, or any skill where deeper reasoning improves output quality.

**Pattern**:
```markdown
## Process

### 1. Deep Analysis

ultrathink

Analyze the codebase considering:
- [complex criteria requiring extended reasoning]
```

**Tradeoff**: Extended thinking increases latency and token usage. Only use for skills where reasoning depth meaningfully improves results.

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

Skills are loaded in priority order (highest to lowest):

1. **Enterprise skills** (organization-wide)
2. **Personal skills** (`~/.claude/skills/`)
3. **Project skills** (`.claude/skills/`)
4. **Plugin skills** (MCP plugins)

**When to use each level**:
- **Personal skills** (`~/.claude/skills/`): Role-specific workflows that apply across all your projects (e.g., your PR style, personal code review checklist). Available only to you, not committed to any repo.
- **Project skills** (`.claude/skills/`): Team-shareable, project-specific workflows committed to the repo. All team members get them automatically.
- **Enterprise skills**: Organization-wide standards enforced across all projects and users.
- **Plugin skills**: Distributed via MCP plugins for cross-project reuse without committing to individual repos. Useful for shared tooling across an organization's repos.

**Best practices**:
- **Don't duplicate**: Check existing skills at all levels before creating new ones
- **Promote upward**: If a personal skill proves useful across the team, move it to project level
- **Keep personal lean**: Only keep skills in `~/.claude/skills/` that are truly personal preference

### Monorepo & Plugin Namespacing

- **Monorepo auto-discovery**: Nested `.claude/skills/` directories in subdirectories are auto-loaded. Each package in a monorepo can define its own skills without collisions
- **Plugin namespace**: Plugin skills use `plugin-name:skill-name` format (e.g., `my-plugin:deploy`) to prevent collisions with project or personal skills of the same name
