---
name: jira
description: >-
  User asks to "create Jira tickets", "decompose into tickets", "file tickets from plan",
  or mentions "Jira" in context of creating tickets from a plan.
  Requires an approved plan in .planning/STATE.md — redirects to /plan if none exists.
  Not for: mentioning a Jira ticket ID as context for other work (use /plan or /feature).
argument-hint: "[PROJECT]"
allowed-tools: Read, Bash(acli jira workitem search *, acli jira workitem view *, acli jira workitem create *, acli jira workitem update *, acli jira workitem edit *, acli jira workitem transition *, acli --version)
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`

## Iron Laws

> - NEVER execute `delete` or any destructive/administrative acli command — if requested, refuse and direct the user to manage these directly in Jira
> - NEVER create or modify a ticket without user confirmation
> - NEVER apply bulk `update`, `edit`, or `transition` operations without first listing all affected ticket IDs and getting explicit user confirmation

## Input Handling

Default project: `UN`. Override via `$ARGUMENTS` (e.g., `/jira PROJ`).

### Pre-flight

1. **Check for plan**: Read `.planning/STATE.md`
   - If the file does not exist or contains no `#### Phase` headings → **stop** and redirect:
     > "No approved plan found. Run `/plan` first to create an implementation plan, then come back to `/jira` to decompose it into tickets."
   - If the file exists with phases → proceed to Process
2. **Check acli availability**: run `acli --version`; available → create directly via acli; unavailable → generate content for manual entry

---

## Process

### 1. Load Plan

Read `.planning/STATE.md` and extract each phase's goal, observable truths, dependencies, files to create/modify, and verification commands.

### 2. Draft Ticket Set

For each plan phase, draft a ticket:
- **Type**: Task (default); Story if user-facing value
- **Acceptance criteria**: each observable truth from the phase
- **Technical details**: files to create/modify and verification commands from the phase
- **Dependencies**: list blocking ticket titles (resolved to IDs after creation)
- **Suggested Story Points**: estimate based on phase scope:
  - 1 pt — single file, trivial change
  - 2 pts — 2-4 files, clear implementation path
  - 3 pts — 5+ files or new integration point
  - 5 pts — cross-cutting concern or significant unknowns
  - 8 pts — consider splitting the phase

Present the full ticket set as a markdown table with columns: #, Summary, Type, Story Points, Depends On.

### 3. Create Tickets

For each ticket in dependency order:

1. **Check for duplicates** — use `acli jira workitem search --jql` to search for tickets with a similar summary; if found, present them before proceeding
2. **Create via acli** (or generate copy-ready content if unavailable):
   - Run `acli jira workitem create --project <KEY> --type <TYPE> --summary "<SUMMARY>" --description "<DESC>"`
   - **Only these four flags are supported** — do NOT pass `--priority` or any other flags
   - Priority is embedded in the description via the template's "Suggested Priority" field; default to Medium if no signal

### 4. Present Manifest

After all tickets are created, output the manifest and store it in `.planning/STATE.md` under a `## Tickets` section for use by `/feature`:

| Ticket ID | Summary | Branch Name |
|-----------|---------|-------------|
| UN-1234 | ... | UN-1234-short-description |
| UN-1235 | ... | UN-1235-short-description |

---

## Related Skills

Pipeline order: `/plan` → `/jira` → `/feature` → `/verify` → `/review` → `/pr`
