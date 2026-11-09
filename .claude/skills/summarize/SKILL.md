---
name: summarize
description: >-
  Turns the current session's investigation, research, or context into a Slack message ready to post.
  User asks to "summarize", "recap", "write up", "share this", "update the team", "update stakeholders",
  "draft a status update", or "post to Slack" about the work done in this session.
  Defaults to a plain-language, non-technical post; produces a technical version when asked
  ("technical", "for engineers", "include details").
  Not for: PR descriptions (use /pr); not for: Confluence pages or blog posts (use /confluence);
  not for: Jira tickets (use /jira); not for: summarizing a file or document unrelated to the session's work.
argument-hint: "[optional: technical | for engineers | include details | audience or channel hint]"
allowed-tools: Read, AskUserQuestion
---

Turn this session's work into a Slack message the user can paste as-is. `$ARGUMENTS` may name the
audience, the channel, or the version ("technical"). Worked examples live in `references/examples.md`
(relative to this skill directory; at user level, `~/.claude/skills/summarize/references/examples.md`).

## 1. Gather

Review the **whole** session, not just the last few turns. Collect:

- The original problem or question
- What was checked, and what was ruled out
- Findings
- The **outcome**: root cause, recommendation, answer, or "not yet known"
- Decisions made, and open questions
- Next steps, each with owner and date where the session gave them

Tag every finding **confirmed** (seen in evidence this session) or **likely** (inferred, not
verified). Never invent details — no made-up numbers, owners, dates, or causes.

Assumptions are allowed only about *form* (audience, scope, which thread to cover) — never about
*facts*. When a fact is missing, say so in the message: "Owner: TBD", "impact not yet measured".
Ask (`AskUserQuestion`) only when it blocks — e.g. the session has no substantive work, or it covers
several unrelated topics with no clear main one. Otherwise pick the dominant thread and note that
choice as an assumption.

## 2. Classify the session

The shape of the TL;DR depends on what kind of work it was:

| Session type | TL;DR states | Findings are | Asks usually |
|--------------|--------------|--------------|--------------|
| **Resolved** (debugging, incident, fix) | The cause and that it is fixed / not yet fixed | What broke and why | Approve or deploy the fix |
| **Research / comparison** | The recommendation, or "no clear winner" | One bullet per option: key trade-off | The decision itself |
| **In progress** (no conclusion yet) | Status: "still investigating", plus what is known so far | Grouped *Confirmed* / *Ruled out* / *Suspected* | Help, access, or info that unblocks |

For **in progress**: never phrase a suspicion as a cause. Next steps must include the next check and
when the next update will come (or "next update: TBD").

## 3. Choose the audience

**Default: non-technical.** Plain language, impact first. Leave out jargon, code, stack traces, file
paths, hostnames, and internal IDs (ticket numbers, commit SHAs, service names). If a technical term
is unavoidable, explain it in a few words — "an expired security certificate (the file that proves
our site is genuine)". See the *avoid → prefer* pairs in `references/examples.md`.

**Technical** only when the user asks ("technical", "for engineers", "include details", "for the
dev channel"). It adds: root-cause specifics, evidence (log lines, queries, commits, PR/ticket links),
reproduction steps, and fix details.

## 4. Structure

Same sections for both versions, in this order. **Skip any section that would be empty** — never
write "N/A".

1. *TL;DR* — one sentence with the conclusion (or status, for in-progress)
2. *Context* — what happened or what was asked
3. *Findings*
4. *Impact* — who or what is affected, and how much. Use real numbers only; otherwise "not yet measured"
5. *Next steps* — action, owner, date
6. *Asks / decisions needed*

## 5. Slack formatting (mrkdwn)

- `*bold*` (single asterisks) for section labels — not `**bold**`
- `•` or `-` for bullets; `<https://url|link text>` for links
- **No** `#` headers, **no** tables — Slack doesn't render them
- `` `inline code` `` and ```` ``` ```` code blocks **only in the technical version**
- `@mentions` only for names or handles the user gave; otherwise write the role ("payments team")
  or "Owner: TBD"
- **Length:** keep the non-technical main post under ~150 words. If it runs long — common for
  comparisons and technical write-ups — split it into a short *main post* (TL;DR, Impact, Asks) plus
  a *thread reply* with the details. Label the two parts clearly.

## 6. Safety

Before output, strip: secrets, tokens, API keys, passwords, connection strings, customer PII
(names, emails, phone numbers, account or loan IDs tied to a person), and internal hostnames or IPs —
in **both** versions — unless the user explicitly says to keep them. Replace with a neutral
placeholder (`<redacted-host>`, "a customer"). Repo, PR, and ticket links may stay in the technical
version; they are not secrets.

Note what was removed in the assumptions line (§8) — the category, never the value.

## 7. Tone

Neutral, factual, blame-free. Describe systems and events, not people: "the certificate wasn't
renewed", not "X forgot to renew it". Be explicit about certainty — use "confirmed" and "likely"
deliberately, and never upgrade one to the other for a cleaner story.

## 8. Output

1. The message inside a fenced block opened and closed with **four** backticks, so triple-backtick code
   blocks inside a technical post don't break the copyable block. For a split post, use one block for
   the main post and one for the thread reply, each with a one-word label above it.
2. One line: `Assumptions: …` — audience chosen, thread covered, anything missing (TBD owners/dates),
   anything redacted. Write `Assumptions: none` if there are none.
3. One line offering to switch audience (technical ↔ non-technical) or length (shorter / split /
   single post).

Don't add commentary beyond those lines, and don't post to Slack yourself — the user posts it.

## Related Skills

- `/pr` — pull request descriptions for the same work
- `/confluence` — a longer write-up or postmortem page
- `/jira` — turn the next steps into tickets
- `/cross-check` — confirm a conclusion before announcing it
