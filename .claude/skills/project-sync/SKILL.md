---
name: project-sync
description: >-
  User asks to "sync docs", "update CLAUDE.md", "audit project documentation",
  "check documentation drift", or "is CLAUDE.md up to date".
  Not for: creating new skills (use /skill-creator) or reviewing code quality (use /review).
argument-hint: "[optional: --dry-run, --section structure|conventions|tasks]"
disable-model-invocation: true
allowed-tools: Bash(git log *, git diff *, git blame *), Read, Grep, Glob, Edit
---

**Current branch:** !`git branch --show-current`
**Skills:** !`ls -d .claude/skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' '`
**Agents:** !`ls .claude/agents/*.md 2>/dev/null | wc -l | tr -d ' '`
**Rules:** !`ls .claude/rules/*.md 2>/dev/null | wc -l | tr -d ' '`

Audit CLAUDE.md for factual drift and broken cross-references, then apply targeted fixes — only when the finding is clear and the update adds genuine value.

## Sync Philosophy

- **Accuracy over coverage** — fix factual errors before adding new content; a wrong count is worse than a missing paragraph
- **Derivable means deletable** — if a future session can figure it out by reading the code or running `ls`, it doesn't belong in CLAUDE.md; document the "why", not the "what"
- **Present findings before editing** — always show what you found and what you propose to change; never silently modify CLAUDE.md
- **Targeted edits, not rewrites** — use Edit on specific lines; rewriting sections destroys intentional phrasing the author chose
- **Conservative by default** — when uncertain whether a finding warrants a CLAUDE.md update, skip it; the cost of clutter exceeds the cost of a missing note

## Input Handling

Use `$ARGUMENTS` if provided.

| Input | Intent | Approach |
|-------|--------|----------|
| `--dry-run` | Audit only, no edits | Run all checks, present findings, stop before Step 6 |
| `--section structure` | Audit Project Structure section only | Compare directory tree claims against filesystem |
| `--section conventions` | Audit Conventions section only | Verify rule file references; check for unlisted rules |
| `--section tasks` | Audit Common Tasks section only | Verify referenced skills and scripts exist |
| (none) | Full audit | Run all checks, present findings, apply confirmed edits |

## Process

### 1. Pre-flight

- Read `CLAUDE.md` into context
- Parse into sections (split on `## ` headings) to scope edits
- Confirm we are in a git repo via `git log`
- If `--section` is provided, narrow scope to that section only

**Stop conditions:**
- `CLAUDE.md` does not exist → report and suggest `/skill-creator` for scaffolding
- Not a git repo → skip drift detection, proceed with structural audit only and note the limitation
- `--section` names a heading not found in CLAUDE.md → list available headings and ask user to choose

### 2. Structural Audit

Compare CLAUDE.md claims against filesystem reality:

| Check | Method | Example Drift |
|-------|--------|---------------|
| Skill count | Glob `.claude/skills/*/SKILL.md`, compare to stated count | "15 skills" but 17 exist |
| Agent count | Glob `.claude/agents/*.md`, compare to stated count | "5 agents" but 6 exist |
| Rule file list | Glob `.claude/rules/*.md`, compare to listed files | `security.md` listed but `architecture.md` not mentioned |
| Directory tree | Parse the code block in Project Structure section | Tree shows dirs that don't exist or misses new ones |
| Referenced file paths | Extract paths from CLAUDE.md, verify each exists | `validate-skill.sh` referenced but path changed |
| Common Tasks backtick-commands | Extract `/skill-name` references, verify skills exist | `/deploy` mentioned but no deploy skill exists |

### 3. Cross-Reference Audit

Scan all skills for broken cross-references:

- Read every `## Related Skills` table across all `.claude/skills/*/SKILL.md` files
- For each `/skill-name` entry, verify `.claude/skills/skill-name/SKILL.md` exists
- Flag references to non-existent skills as broken

### 4. Drift Detection

Use git history to find undocumented additions:

- `git log --oneline --diff-filter=A -- .claude/skills/` to find skills added after CLAUDE.md was last touched
- `git log --oneline --diff-filter=A -- .claude/rules/` for new rule files
- `git log --oneline --diff-filter=A -- .claude/agents/` for new agents
- `git log --oneline -- CLAUDE.md` to get CLAUDE.md's last commit date
- Flag any skills/rules/agents added after that date as potential drift

### 5. Present Findings

Output a structured report before any edits:

```
## Documentation Audit Report

### Factual Errors (will fix)
- [ ] Skill count: CLAUDE.md says 15, actual is 17

### Drift Detected (recommend fix)
- [ ] 2 skills added since last CLAUDE.md update: `hookify`, `confluence`

### Broken Cross-References
- [ ] `/deploy` referenced in `feature/SKILL.md` Related Skills but no deploy skill exists

### Suggestions (optional — skipped unless you confirm)
- Consider documenting: /plan → /feature → /verify → /finish workflow chain

### No Action Needed
- Agent count is accurate
- All rule file references resolve
```

If `--dry-run`, stop here. Otherwise ask user to confirm before proceeding to Step 6.

### 6. Apply Updates

For each confirmed finding, use `Edit` to update the specific lines in CLAUDE.md:

- Count corrections: update the number inline (e.g., `15` → `17`)
- Missing references: append to the relevant list, matching existing format and indentation
- New skills/agents/rules: add bullet using same style as existing entries
- Never rewrite prose — only correct factual claims

After edits, re-read CLAUDE.md to confirm changes look correct.

## Output Principles

- **Report before edit** — the full findings report always precedes any CLAUDE.md modification
- **Categorize by confidence** — Factual Errors (certain) vs. Drift (likely) vs. Suggestions (optional)
- **Cite evidence** — every finding references the CLAUDE.md line and the filesystem evidence that contradicts it
- **Minimal diff** — if a finding requires more than 5 lines of change, flag it for manual review instead of applying automatically

## Error Handling

| Scenario | Response |
|----------|----------|
| `CLAUDE.md` does not exist | Report; suggest using `/skill-creator` patterns to create one |
| Not a git repo | Skip drift detection; proceed with structural audit only; note limitation |
| Shallow clone (no history) | Skip drift detection; proceed with structural audit only |
| CLAUDE.md has no `## ` section headings | Warn that audit is limited to count/reference checks; continue |
| `--section` argument not found in CLAUDE.md | List available section headings; ask user to choose |
| User declines all proposed changes | Report "No changes made" and exit cleanly |
| Edit conflicts with concurrent changes | Re-read CLAUDE.md, re-verify finding still applies, then retry |

Never silently skip a check — surface what was checked, what was skipped, and why.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/skill-creator` | Creating or scaffolding a new skill, not auditing docs |
| `/review` | Reviewing code quality, not documentation accuracy |
| `/verify` | Verifying implementation completeness against a plan |
| `/finish` | Wrapping up a branch; consider running `/project-syncing` first |
| `/plan` | Planning new work; `/project-syncing` captures what already happened |
