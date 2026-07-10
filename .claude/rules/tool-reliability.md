# Tool Reliability

Applies to every skill or agent that depends on an external tool — CLI (`psql`, `gh`, `acli`, `aws`, …) or an MCP server.

## Iron Laws

- **A tool that fails is not a tool that found nothing.** A connection error, auth failure, timeout, or missing binary is never an empty or negative result.
- **Never silently fall back.** If a tool that was meant to ground the work cannot run, do not substitute code, cache, memory, or assumption as the source of truth without telling the user first.

## On Failure — Pause and Inform

When a required CLI/MCP call fails (nonzero exit, auth/connection error, timeout, tool unavailable):

1. **Stop** the affected step — do not proceed as if the check passed.
2. **Report** to the user, one line each: which tool, the failing command or server, and the error.
3. **Offer choices**: retry, proceed without that grounding (explicitly naming the gap and what stays unverified), or abort.
4. If the user chooses to proceed, **label** every downstream conclusion that relied on the missing tool as unverified.

## Subagents

An agent whose tool fails must return an explicit failure signal to its caller — not an empty or degraded report. The caller must surface that signal to the user, not swallow it.
