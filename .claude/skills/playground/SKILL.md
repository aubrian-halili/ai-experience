---
name: playground
description: >-
  User asks to "create a quick demo", "build a prototype", "show me what this looks like",
  or wants a throwaway single-file HTML prototype for visual exploration.
  Not for: production UI components (use /react or /frontend-design),
  Mermaid diagrams (use /diagram).
argument-hint: "[type of playground or concept to visualize]"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash(open *)
---

Generate self-contained HTML playgrounds for rapid prototyping, visual exploration, and stakeholder demos.

## Playground Philosophy

- **Zero dependencies** — every playground is a single HTML file with embedded CSS and JS; no build tools, no CDN links, no frameworks
- **Instant gratification** — generate and open in browser immediately; the value is in speed, not polish
- **Interactive by default** — static mockups belong in design tools; playgrounds should respond to user interaction
- **Disposable** — playgrounds are experiments, not production code; optimize for learning and demonstration speed

## When to Use

### This Skill Is For

- Rapid visual prototyping of UI concepts
- Interactive data exploration (tables, filters, charts)
- Concept maps and relationship visualization
- Component showcases for design discussions
- Quick demos for stakeholder feedback
- Visual debugging of CSS layouts or animations

### Use a Different Approach When

- Building production UI components → use `/react`
- Creating polished design systems → use `/frontend-design`
- Writing documentation with diagrams → use `/diagram`
- Full application scaffolding → use `/feature`

## Input Classification

Classify `$ARGUMENTS` to determine the playground type:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Explore options | Show available templates, ask what to build |
| Concept description (e.g., `color palette explorer`) | Custom playground | Design and build from scratch |
| Template name (e.g., `data explorer`) | Use template | Scaffold from `@references/templates.md` |
| File path (e.g., `src/data.json`) | Data playground | Build explorer around the data |

## Process

### 1. Pre-flight

- Classify playground type from `$ARGUMENTS` using the Input Classification table
- If a data file is referenced, verify it exists and read its structure
- Determine output path: default to `playground-<name>.html` in current directory

**Stop conditions:**
- No `$ARGUMENTS` and no clear playground concept → show available templates and ask
- Request is for a production component → redirect to `/react` or `/frontend-design`

### 2. Design

Plan the playground structure:

1. **Layout**: Choose responsive layout (single panel, split panel, dashboard grid)
2. **Interactivity**: Identify what the user can manipulate (filters, sliders, drag, toggle)
3. **Data**: Determine data source (hardcoded sample, user-provided, generated)
4. **Visual style**: Use CSS variables for easy theming; default to a clean, modern look

### 3. Build

Generate a single self-contained HTML file:

1. Write HTML structure with semantic elements
2. Embed CSS in `<style>` tag using CSS variables for theming
3. Embed JS in `<script>` tag for interactivity
4. Include sample data inline if needed
5. Add responsive meta viewport tag

Key constraints:
- No external dependencies (no CDN links, no imports)
- Must work offline
- Must be responsive (works on mobile and desktop)
- Use modern CSS (grid, flexbox, custom properties) and modern JS (ES6+)

### 4. Open

Auto-open the generated file in the default browser:

```bash
open playground-<name>.html  # macOS
```

### 5. Iterate

If the user requests changes:
- Edit the existing playground file
- Re-open in browser to show updates
- Keep changes minimal and focused

## Output Principles

- **Single file** — everything in one HTML file; no external assets
- **Responsive** — works on any screen size without scrollbar issues
- **Themed** — CSS variables at the top for easy color/spacing customization
- **Commented** — key sections have brief comments for easy modification by the user

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Show available playground templates and ask what to build |
| Concept description (e.g., `kanban board`) | Design and build a custom playground |
| Template name (e.g., `data explorer`) | Scaffold from template with sample data |
| Data file path (e.g., `data.json`) | Build an explorer around the provided data |
| `list` | Show all available templates with descriptions |

## Error Handling

| Scenario | Response |
|----------|----------|
| Data file not found | Report missing path, offer to create with sample data |
| Data file too large (>1MB) | Suggest sampling or pagination approach |
| Browser doesn't open | Provide the file path for manual opening |
| Complex visualization requested | Suggest breaking into multiple simpler playgrounds |
| Request requires external API | Embed mock data instead; note the limitation |
| SVG/canvas rendering needed | Use inline SVG or canvas API; no external libraries |

Never include external CDN links or npm packages — the playground must work completely offline.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/react` | Building production React components |
| `/frontend-design` | Design system and visual polish guidance |
| `/diagram` | Mermaid diagrams for documentation |
| `/docs` | Written documentation rather than interactive demos |
