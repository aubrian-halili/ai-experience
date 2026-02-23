---
name: docs
description: Use when the user asks to "write documentation", "create docs", "document this", "technical writing", "create a presentation", "make slides", "build a deck", mentions "README", "API docs", "RFC", "design doc", "PowerPoint", "slides", "deck", or needs technical documentation, presentations, and stakeholder communication.
argument-hint: "[topic, document type, or presentation purpose]"
allowed-tools: Read, Grep, Glob, Write
---

Create and improve technical documentation, presentations, and stakeholder communications.

## Documentation Philosophy

- **Lead with the point** — state the main idea first; bury the lede and readers stop reading
- **Use active voice** — "The function returns" not "A value is returned"; active voice is shorter and clearer
- **Be specific** — "Returns in 50ms" not "Returns quickly"; vague claims erode trust
- **Show, don't tell** — use code examples liberally; one working example teaches more than three paragraphs
- **Define acronyms** — spell out on first use; readers should never have to guess terminology

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

## Input Classification

Determine documentation workflow from `$ARGUMENTS`:

| Input | Intent | Approach |
|-------|--------|----------|
| Topic (e.g., `auth system`) | Create new docs | Steps 1-4; determine type in pre-flight |
| Type flag (`--readme`, `--api`, `--rfc`, etc.) | Specific doc type | Steps 1-4; skip type classification |
| `--slides [topic]` | Create presentation | Steps 1-4; apply Presentation Guidelines |
| Existing doc path (e.g., `docs/api.md`) | Update/improve docs | Steps 1, 3-4; read existing content first |
| (none) | Ask user | Pre-flight stop |

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

- Classify request using the Input Classification table
- Determine specific document type using the Document Types table
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

- **One message per slide** — don't overload; each slide should answer exactly one question
- **6x6 rule** — max 6 bullets, 6 words each; dense slides lose the audience
- **Lead with conclusion** — pyramid principle; state the recommendation first, then supporting evidence
- **Use diagrams** — visualize architecture and data flow; a diagram replaces a thousand words of description

## Presentation Types

| Type | Structure | Focus |
|------|-----------|-------|
| **Architecture Review** | Current → Challenges → Proposed → Migration → Risks | Design decisions |
| **Technical Proposal** | Problem → Goals → Solution → Alternatives → Plan | Implementation details |
| **Project Update** | Summary → Accomplishments → Metrics → Blockers → Plans | Progress status |
| **Executive Summary** | Key Message → Context → Recommendation → Investment → ROI | Business value |

## Output Principles

- **Template-driven structure** — every document follows a template from `@references/templates.md`; consistent structure reduces cognitive load for readers
- **Audience-calibrated depth** — match technical depth to the target audience identified in the Document Types table; an executive summary is not an RFC
- **Reviewable drafts** — always present the full document for user review before writing to disk; documentation is collaborative
- **Actionable completeness** — mark unfinished sections with `[TBD]` rather than omitting them; visible gaps are better than invisible ones

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

Never write a document to disk without user approval or silently omit incomplete sections — surface gaps as `[TBD]` and state audience assumptions explicitly.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/diagram` | Visual documentation only |
| `/architecture` | Designing system before documenting |
| `/architecture --adr` | Recording architecture decisions |
| `/explore` | Understanding system before documenting |
