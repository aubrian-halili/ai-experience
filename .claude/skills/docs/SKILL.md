---
name: docs
description: Use when the user asks to "write documentation", "create docs", "document this", "technical writing", "create a presentation", "make slides", "build a deck", mentions "README", "API docs", "RFC", "design doc", "PowerPoint", "slides", "deck", or needs technical documentation, presentations, and stakeholder communication.
argument-hint: "[topic, document type, or presentation purpose]"
allowed-tools: Read, Grep, Glob, Write
---

Create and improve technical documentation, presentations, and stakeholder communications.

## Documentation Philosophy

1. **Lead with the point** — State the main idea first
2. **Use active voice** — "The function returns" not "A value is returned"
3. **Be specific** — "Returns in 50ms" not "Returns quickly"
4. **Show, don't tell** — Use code examples liberally
5. **Define acronyms** — Spell out on first use

## When to Use

### This Skill Is For

- Writing README files and project documentation
- Creating API documentation
- Drafting RFCs and design documents
- Technical specification writing
- Architecture review presentations
- Technical proposal decks
- Project status updates
- Executive summaries
- Documentation review and improvement

### Use a Different Approach When

- Creating architecture diagrams only → use `/diagram`
- Recording architecture decisions → use `/architecture --adr`
- Code-level comments → handle inline during development

## Document Types

| Type | Purpose | Audience | Format |
|------|---------|----------|--------|
| **README** | Project overview, quick start | New users, contributors | Markdown |
| **API Docs** | Endpoint reference | Developers integrating | Markdown |
| **RFC** | Propose significant changes | Team, stakeholders | Markdown |
| **Design Doc** | Technical design details | Engineers implementing | Markdown |
| **Runbook** | Operational procedures | Ops, on-call engineers | Markdown |
| **Presentation** | Visual communication | Various audiences | Slides outline |
| **Executive Summary** | Business value, ROI | C-level, stakeholders | Slides outline |

## Process

### 1. Pre-flight

Parse `$ARGUMENTS` to determine document type and topic.

- Classify using the Document Types table above
- Check for existing documentation in the project (README, docs/, etc.)
- If updating existing docs, read the current content first

**Stop conditions:**
- No topic or type specified → ask user what to document
- Unclear audience → ask who will read the document
- Existing document found at target path → ask whether to update or create new

### 2. Gather & Structure

- Read relevant source code, existing docs, and dependencies
- Identify key concepts, APIs, and examples
- Select appropriate template from `@references/templates.md`
- Build content outline following the template structure
- For presentations, apply Presentation Guidelines below

### 3. Present for Review

- Show the proposed document: type, target path, full content
- Ask the user to review and confirm before writing to disk
- If changes requested, revise and present again

### 4. Write & Verify

- **Only proceed after user approval**
- Create the target directory if it doesn't exist
- Write the document to disk
- Verify the file was created successfully
- Note any sections marked `[TBD]` that need follow-up

## Presentation Guidelines

1. **One message per slide** — Don't overload
2. **6x6 rule** — Max 6 bullets, 6 words each
3. **Lead with conclusion** — Pyramid principle
4. **Use diagrams** — Visualize architecture and data flow

## Presentation Types

| Type | Structure | Focus |
|------|-----------|-------|
| **Architecture Review** | Current → Challenges → Proposed → Migration → Risks | Design decisions |
| **Technical Proposal** | Problem → Goals → Solution → Alternatives → Plan | Implementation details |
| **Project Update** | Summary → Accomplishments → Metrics → Blockers → Plans | Progress status |
| **Executive Summary** | Key Message → Context → Recommendation → Investment → ROI | Business value |

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Ask what to document |
| Topic (e.g., `auth system`) | Create documentation for the topic, ask document type if unclear |
| `--readme` | Generate project README |
| `--api` | Generate API documentation |
| `--rfc [title]` | Generate RFC document |
| `--design [title]` | Generate design document |
| `--runbook [topic]` | Generate operational runbook |
| `--slides [topic]` | Generate presentation outline |

## Error Handling

| Scenario | Response |
|----------|----------|
| Unclear scope | Ask what should be documented |
| Missing context | Request access to relevant code |
| Outdated docs | Flag discrepancies found |
| Complex topic | Break into multiple documents |
| Unclear audience | Ask who will view the content |
| Too much content | Suggest splitting or using appendix |
| Existing file at target path | Ask user whether to overwrite, update, or choose a different path |
| Target directory missing | Create the directory, then write |
| Template not applicable | Adapt the closest template or build a custom structure |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/diagram` | Visual documentation only |
| `/architecture` | Designing system before documenting |
| `/architecture --adr` | Recording architecture decisions |
| `/explore` | Understanding system before documenting |
