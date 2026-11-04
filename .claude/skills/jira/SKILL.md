---
name: jira
description: >-
  User asks to "create Jira tickets", "decompose into tickets", "file tickets from plan",
  "break plan into Jira", or mentions "Jira" in context of creating tickets from a plan.
  Requires an approved plan in .planning/STATE.md (redirects to /plan if missing).
  Defaults to project UN (overridable); uses acli when available, otherwise emits copy-ready content.
  Not for: mentioning a Jira ticket ID as context for other work (use /plan or /feature); not for: transitioning or editing existing tickets.
argument-hint: "[PROJECT]"
allowed-tools: Read, Write(.planning/STATE.md), Write(.planning/tickets/*.md), Write(.planning/tickets/*.json), Edit(.planning/STATE.md), Agent, Bash(acli jira workitem search *, acli jira workitem view *, acli jira workitem create *, acli jira workitem create-bulk *, acli jira workitem edit *, acli jira workitem link *, acli --version, python3 .claude/skills/jira/scripts/build-workitem.py *, python3 .claude/skills/jira/scripts/build-bulk.py *)
disable-model-invocation: true
---

## Input Handling

Default project: `UN`. Override via `$ARGUMENTS` (e.g., `/jira PROJ`).

### Pre-flight

1. **Check for plan**: Read `.planning/STATE.md` and extract each phase's goal, observable truths, and dependencies.
   - If the file does not exist or contains no `#### Phase` headings → **stop** and redirect:
     > "No approved plan found. Run `/plan` first to create an implementation plan, then come back to `/jira` to decompose it into tickets."
2. **Check acli availability**: run `acli --version`. If unavailable, tell the user and switch to **manual mode**: do §1–2, write the §3 description files and output them with the §2 table for manual entry. Skip the duplicate check, payload build, creation, and §4. In §5, ask the user for the IDs they created; if they don't have them yet, leave `### Tickets` unchanged rather than writing placeholder IDs.

---

## Process

### 1. Choose Ticket Granularity

Ask the user:

> "Create one ticket per plan phase, or a single ticket covering all phases?"

- **Per-phase**: proceed with one ticket per phase as below.
- **Single ticket**: draft one Task whose summary reflects the overall plan goal, with acceptance criteria = union of all observable truths across phases.

### 2. Draft & Confirm

**If per-phase:** for each plan phase, draft a ticket:
- **Type**: Task (default); Story if user-facing value
- **Acceptance criteria**: each observable truth from the phase
- **Dependencies**: list blocking ticket titles (resolved to IDs in §4)

Show as table — columns: #, Summary, Type, Depends On — then ask the user to confirm, edit, or cancel.

### 3. Create Tickets

1. **Check for duplicates** — launch one `jira-explorer` agent with the project key and the drafted ticket summaries as its research question, asking for one duplicate sweep per ticket. Surface any `possible duplicate` matches (and the terms it swept), and for each flagged ticket ask whether to **skip** it (use the existing key in §4 and the manifest) or **create anyway**. On a `### Tool Failure`, apply `.claude/rules/tool-reliability.md`; "proceed" means create anyway, stating that duplicate detection did not run.
2. **Write the description** to `.planning/tickets/<n>.md`, using this template verbatim:
   ```
   ## Summary
   <1–2 sentence problem statement from the phase goal>

   ## Acceptance Criteria
   - <observable truth 1>
   - <observable truth 2>

   ## Dependencies
   - <blocking ticket title or "None">

   ## Suggested Priority
   <Critical|High|Medium|Low> — <brief justification>
   ```
   **Stay inside the supported constructs** — headings, `- ` bullets, paragraphs, `` `inline code` ``, and `[label](url)` links. No `**bold**`, `*italic*`, `~~strike~~`, `__underline__`, or raw HTML; wrap file paths, commands, and globs in backticks so `*` characters inside them are treated as literal.

3. **Build the work item payload** — `acli` stores plain text verbatim (raw markdown renders as literal `##` and `-`), so convert the description to ADF:
   ```bash
   python3 .claude/skills/jira/scripts/build-workitem.py .planning/tickets/<n>.md \
     --project <KEY> --type <TYPE> --summary "<SUMMARY>" \
     [--label <l>] [--parent <ID>] \
     > .planning/tickets/<n>.json
   ```
   - **`--parent`** maps to acli's `parentIssueId`, which its schema documents as sub-task only. Passing an epic as the parent of a Story or Task is untested — if creation fails on it, retry without `--parent`, then add a `Relates` link to the epic in §4 and tell the user the epic **parent** field still needs setting in Jira (a link is not epic parentage).

   On non-zero exit (reason on stderr), apply `.claude/rules/tool-reliability.md` — the proceed option here is creating with a plain-text `--description`, stating that the ticket body will not render.

4. **Create via acli** — one ticket at a time by default:
   - Run `acli jira workitem create --from-json .planning/tickets/<n>.json` with no other flags — in particular **not `--priority`**, which is not a valid flag (priority stays as the "Suggested Priority" section in the description).

   **Bulk path (4+ tickets, same project).** Offer `create-bulk` to collapse the loop into one call. List this run's payload files explicitly — a glob also matches `links.json`, `bulk.json`, and leftovers from earlier runs:
   ```bash
   python3 .claude/skills/jira/scripts/build-bulk.py \
     .planning/tickets/1.json .planning/tickets/2.json ... \
     > .planning/tickets/bulk.json
   acli jira workitem create-bulk --from-json .planning/tickets/bulk.json --yes
   ```
   `build-bulk.py` refuses any ticket carrying a custom field (`--field`) or a `reporter`, since `create-bulk` would silently drop them; follow the remedy its error names.

   **Verify the render once per project.** ADF handling on the bulk path is unconfirmed. After the first bulk run against a project, run `acli jira workitem view <NEW-KEY> --fields description --json`: if the description is a plain string instead of an ADF doc, the bodies rendered as literal `##` and `-`. Repair each with `build-workitem.py --adf-only` piped to `acli jira workitem edit --key <KEY> --description-file <file> --yes`, and use the per-ticket path for the rest of the run.

### 4. Link Dependencies

Once every ticket has an ID, write `.planning/tickets/links.json` (Write tool) as a bare array, then create the links:

```json
[
  { "outwardIssue": "UN-1234", "inwardIssue": "UN-1235", "type": "Blocks" }
]
```

```bash
acli jira workitem link create --from-json .planning/tickets/links.json --yes
```

- **Direction matters**: if ticket B depends on A, then A is `outwardIssue` and B is `inwardIssue`.
- Use `Blocks` for dependencies and `Relates` for the epic fallback in §3; if a type is rejected, list valid ones with `acli jira workitem link type`.
- The links are additive, so on failure leave the created tickets in place — the user can add links in Jira without redoing creation.

### 5. Present Manifest

Output the manifest and store it in `.planning/STATE.md` under the existing `### Tickets` heading:

| Ticket ID | Summary | Branch Name | Blocked By | Status | PR |
|-----------|---------|-------------|------------|--------|----|
| UN-1234 | ... | UN-1234-short-description | — | Open | — |
| UN-1235 | ... | UN-1235-short-description | UN-1234 | Open | — |

`Blocked By` reflects the links actually created in §4.
