---
name: audit
description: >-
  Audits an answer or a completed task for correctness and completeness by re-deriving it
  independently. User asks "double check that", "are you sure", "verify your answer",
  "did you miss anything", "review the result", or wants the previous response confirmed.
  Also the self-audit pass to run unprompted after answering a question whose answer is an
  enumeration, a count, or a factual claim about the codebase.
  Re-answers the original question from scratch in a fresh context, then reconciles claim by claim.
  Not for: code completeness against a plan (use /verify); code quality of a diff (use /review);
  merge-readiness of a PR or feature (use /gate).
argument-hint: "[the claim or answer to audit, or nothing to audit the previous response]"
allowed-tools: Bash(git *, gh *, rg *), Read, Grep, Glob, Agent, AskUserQuestion
---

ultrathink

Audit the answer named in `$ARGUMENTS`, or — if empty — the most recent substantive answer or
completed task in this conversation.

`references/...` paths are relative to this skill directory. When invoked at user level, resolve
them against `~/.claude/skills/audit/references/...` ($HOME, not the repo working directory).

## 1. Extract the claim set

Restate the prior answer as **discrete checkable assertions** — not a summary. "This service has 4
API integrations" is one count assertion plus four membership assertions plus one *closure*
assertion ("and no others"). The closure assertion is the one that usually fails.

Record, for each assertion, the evidence the original answer cited. An assertion with no cited
evidence starts as **unverified**, never as correct.

## 2. Classify the answer type

| Type | What the audit must prove | Primary failure |
|------|---------------------------|-----------------|
| **Enumeration / count** | The set is closed — nothing outside it qualifies | Undercount from a single search vector |
| **Factual lookup** | The cited source says it, and is current | Stale or misread evidence |
| **Explanation / causal** | The mechanism holds at every step | A plausible step nobody traced |
| **Change / edit** | The change is present, correct, and wired | Reported-done but partial |

For **Change / edit**, delegate to `/verify` instead of re-deriving — that is its job — and audit
only the surrounding claims.

## 3. Re-derive independently

Dispatch one `Agent` (`Explore` or `general-purpose`) with **the original question only**.

**Never include the original answer, its count, or its member list in the agent's prompt.** An agent
shown the answer confirms the answer. Ask it to answer from scratch and report its search vectors.

For enumerations, instruct the agent to widen deliberately: alternate naming conventions, config and
infrastructure declarations (not just code), indirect or generated call paths, dependency manifests,
and disabled or commented-out members. Require `file:line` for every member it returns.

Run the claim-specific hunts in `references/failure-modes.md` in the same message where they are
independent of the re-derivation.

## 4. Reconcile

Compare the fresh derivation against the claim set from §1, assertion by assertion:

- **Agrees, same evidence** → confirmed.
- **Agrees, different evidence** → confirmed, and note the stronger citation.
- **Fresh result has members the original missed** → the original was wrong. State the new total.
- **Original has members the fresh result missed** → do not average the two. Resolve which is right
  by reading the disputed `file:line` directly.
- **A tool or search failed** → **unverified**, never "nothing found". Report the failure per
  `.claude/rules/tool-reliability.md` and name what stays unconfirmed.

Also surface any **scope assumption** the original answer made silently — what counted as "an API
integration", which directories were in scope, whether tests and vendored code counted. A count is
only meaningful with its definition attached; if the definition is genuinely ambiguous and changes
the answer, use `AskUserQuestion`.

## 5. Verdict

Emit the block in `references/templates.md`.
