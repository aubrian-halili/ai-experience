---
name: docs
description: Use when the user asks to "write documentation", "create docs", "document this", "technical writing", "create a presentation", "make slides", "build a deck", mentions "README", "API docs", "RFC", "design doc", "PowerPoint", "slides", "deck", or needs technical documentation, presentations, and stakeholder communication.
argument-hint: "[topic, document type, or presentation purpose]"
---

Create and improve technical documentation, presentations, and stakeholder communications.

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

Use `$ARGUMENTS` if provided (topic, document type, or presentation purpose).

1. **Identify Document Type** — Determine type, audience, detail level, and format
2. **Gather Information** — Review code/docs, identify key concepts, note examples, list dependencies
3. **Structure Content** — Follow appropriate template from `@references/templates.md`
4. **Write with Clarity** — Use clear language, include code examples, add diagrams, define terms
5. **Review and Refine** — Check accuracy, verify code examples work, ensure completeness

See `@references/templates.md` for README, API Docs, RFC, Design Doc, and Presentation templates.

## Writing Guidelines

### Clarity Principles

1. **Lead with the point** — State the main idea first
2. **Use active voice** — "The function returns" not "A value is returned"
3. **Be specific** — "Returns in 50ms" not "Returns quickly"
4. **Show, don't tell** — Use code examples liberally
5. **Define acronyms** — Spell out on first use

### Presentation Guidelines

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

## Error Handling

| Scenario | Response |
|----------|----------|
| Unclear scope | Ask what should be documented |
| Missing context | Request access to relevant code |
| Outdated docs | Flag discrepancies found |
| Complex topic | Break into multiple documents |
| Unclear audience | Ask who will view the content |
| Too much content | Suggest splitting or using appendix |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/diagram` | Visual documentation only |
| `/architecture` | Designing system before documenting |
| `/architecture --adr` | Recording architecture decisions |
| `/explore` | Understanding system before documenting |
