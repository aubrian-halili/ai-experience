---
name: jira
description: >-
  User asks to "create Jira tickets", "decompose into tickets", "file tickets from plan",
  "break plan into Jira", or mentions "Jira" in context of creating tickets from a plan.
  Requires an approved plan in .planning/STATE.md (redirects to /plan if missing).
  Defaults to project UN (overridable); uses acli when available, otherwise emits copy-ready content.
  Not for: mentioning a Jira ticket ID as context for other work (use /plan or /feature); not for: transitioning or editing existing tickets.
argument-hint: "[PROJECT]"
allowed-tools: Read, Bash(acli jira workitem search *, acli jira workitem view *, acli jira workitem create *, acli jira workitem update *, acli jira workitem edit *, acli jira workitem transition *, acli --version)
disable-model-invocation: true
---

**Current branch:** !`git branch --show-current`

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

### 2. Choose Ticket Granularity

Ask the user:

> "Create one ticket per plan phase, or a single ticket covering all phases?"

- **Per-phase** (default): proceed with one ticket per phase as below.
- **Single ticket**: draft one Task whose summary reflects the overall plan goal, with acceptance criteria = union of all observable truths across phases, and technical details listing all files and verification commands. Skip dependency resolution (only one ticket).

### 3. Draft Ticket Set

**If per-phase:** for each plan phase, draft a ticket:
- **Type**: Task (default); Story if user-facing value
- **Acceptance criteria**: each observable truth from the phase
- **Technical details**: files to create/modify and verification commands from the phase
- **Dependencies**: list blocking ticket titles (resolved to IDs after creation)

Show as table — columns: #, Summary, Type, Story Points, Depends On.

### 4. Review & Confirm

Present the drafted ticket(s) — summary, type, acceptance criteria, technical details, dependencies — and ask the user to confirm, edit, or cancel.

### 5. Create Tickets

For each ticket in dependency order:

1. **Check for duplicates** — use `acli jira workitem search --jql` to search for tickets with a similar summary; surface any matches before proceeding
2. **Create via acli** (or generate copy-ready content if unavailable):
   - Run `acli jira workitem create --project <KEY> --type <TYPE> --summary "<SUMMARY>" --description "<DESC>"`
   - **Only these four flags are supported** — do NOT pass `--priority` or any other flags
   - Description template:
     ```
     ## Summary
     <1–2 sentence problem statement from the phase goal>

     ## Acceptance Criteria
     - <observable truth 1>
     - <observable truth 2>

     ## Technical Details
     - Files: <paths>
     - Verification: <commands>

     ## Dependencies
     - <blocking ticket title or "None">

     ## Suggested Priority
     <Critical|High|Medium|Low> — <brief justification>
     ```
   - Note: acli passes `--description` as plain text (no markdown rendering in Jira), but always emit this structure so ticket bodies stay consistent and machine-parseable.

### 6. Present Manifest

After all tickets are created, output the manifest and store it in `.planning/STATE.md` under a `## Tickets` section for use by `/feature`:

| Ticket ID | Summary | Branch Name |
|-----------|---------|-------------|
| UN-1234 | ... | UN-1234-short-description |
| UN-1235 | ... | UN-1235-short-description |

---

## Related Skills

Pipeline order: `/plan` → `/jira` → `/feature` → `/verify` → `/review` → `/pr`
