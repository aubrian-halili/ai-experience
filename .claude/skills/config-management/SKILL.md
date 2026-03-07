---
name: config-management
description: >-
  TRIGGER when: user asks to "audit CLAUDE.md", "update CLAUDE.md", "sync project configuration", "check
  if CLAUDE.md is up to date", "fix stale references in config", or notices CLAUDE.md is out of sync with
  the actual project structure.
  DO NOT TRIGGER when: user wants to create a new skill (use /skill-creator), write project documentation
  (use /docs), or review code quality (use /review). This skill maintains Claude Code configuration files.
argument-hint: "[audit, sync, or improve]"
allowed-tools: Read, Grep, Glob
---

Audit, sync, and improve CLAUDE.md and related configuration files for consistency and completeness.

## Management Philosophy

- **Single source of truth** — CLAUDE.md should accurately reflect the current state of the project; stale references erode trust
- **Structural consistency** — rules, skills, and configuration should cross-reference each other without gaps or contradictions
- **Minimal maintenance burden** — surface actionable discrepancies, not cosmetic suggestions; focus on what breaks workflows
- **Convention over configuration** — document patterns that are actually followed, not aspirational standards

## When to Use

### This Skill Is For

- Auditing CLAUDE.md for stale skill counts, missing cross-references, or outdated file paths
- Syncing CLAUDE.md content with actual directory structure
- Improving CLAUDE.md based on undocumented codebase patterns
- Verifying rules/ files are properly referenced
- Post-skill-creation housekeeping

### Use a Different Approach When

- Creating new skills → use `/skill-creator`
- Reviewing code quality → use `/review`
- Writing documentation for external consumers → use `/docs`

## Input Classification

Classify `$ARGUMENTS` to determine the management mode:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Full audit | Run all three modes sequentially |
| `audit` | Check for inconsistencies | Read-only analysis, report discrepancies |
| `sync` | Update CLAUDE.md to match reality | Propose edits to align with directory contents |
| `improve` | Suggest additions | Analyze codebase for undocumented conventions |

## Process

### 1. Pre-flight

- Classify mode from `$ARGUMENTS` using the Input Classification table
- Verify CLAUDE.md exists at project root
- Check for CLAUDE.local.md (note its presence but do not modify — it's user-private)

**Stop conditions:**
- No CLAUDE.md found → offer to help create one
- Not a skills repository → adjust scope to general CLAUDE.md audit

### 2. Inventory

Gather current state:

1. **Skills inventory**: List all `.claude/skills/*/SKILL.md` files
2. **Rules inventory**: List all `.claude/rules/*.md` files
3. **CLAUDE.md claims**: Extract skill count, skill list, project structure, and rule references from CLAUDE.md
4. **Cross-references**: Collect all Related Skills tables from skill files

### 3. Audit (all modes)

Compare inventories against CLAUDE.md claims:

- **Skill count**: Does the stated count match the actual number of skill directories?
- **Skill list**: Are all skills mentioned? Are any listed skills missing from disk?
- **Project structure**: Does the directory tree in CLAUDE.md match reality?
- **Rule references**: Are all rules/*.md files referenced from CLAUDE.md?
- **Cross-references**: Do Related Skills sections reference skills that exist?
- **File paths**: Do mentioned file paths resolve to actual files?

### 4. Sync (sync and improve modes)

For each discrepancy found in the audit:

- Propose a specific edit with before/after context
- Group edits by file (CLAUDE.md, skill files, rule files)
- Prioritize: broken references > stale counts > missing mentions

### 5. Improve (improve mode only)

Analyze the codebase for patterns not yet documented:

- Scan recent git history for recurring conventions
- Check if frequently used tools or patterns are missing from CLAUDE.md
- Look for common file patterns that could be documented as conventions
- Suggest additions to the Common Tasks or Conventions sections

### 6. Report

Present findings organized by severity:

| Severity | Description | Example |
|----------|-------------|---------|
| **Error** | Broken reference, missing file | Skill listed in CLAUDE.md but directory doesn't exist |
| **Warning** | Stale data | Skill count says 17 but there are 24 skills |
| **Info** | Improvement opportunity | New convention detected but not documented |

## Output Principles

- **Diff-ready suggestions** — show exact edits needed, not vague recommendations
- **Severity-ordered** — errors first, then warnings, then info
- **Non-destructive** — never suggest removing content that might be intentionally aspirational; flag it as a question instead
- **Scoped to config** — only touch CLAUDE.md, rules/, and skill cross-references; do not modify skill logic

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | Run full audit across all modes |
| `audit` | Read-only analysis; report discrepancies without suggesting edits |
| `sync` | Audit + propose specific edits to align CLAUDE.md with reality |
| `improve` | Audit + sync + suggest additions based on undocumented patterns |

## Error Handling

| Scenario | Response |
|----------|----------|
| No CLAUDE.md found | Offer to create a minimal one based on project structure |
| CLAUDE.local.md present | Acknowledge but do not modify; it's user-private |
| Ambiguous skill reference | List candidates and ask user to clarify |
| Very large number of discrepancies | Prioritize by severity; suggest fixing errors first |
| Skill directory exists but SKILL.md is missing | Report as error; suggest running skill-creator validation |
| Rule file referenced but doesn't exist | Report as error with exact reference location |

Never modify CLAUDE.local.md or user-private configuration — only suggest changes to project-level files.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/skill-creator` | Creating or validating individual skills |
| `/review` | Reviewing code quality rather than configuration |
| `/docs` | Writing documentation for external consumers |
| `/explore` | Understanding codebase structure before auditing |
