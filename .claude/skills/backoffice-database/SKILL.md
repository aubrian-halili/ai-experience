---
name: backoffice-database
description: >-
  User asks to "query the database", "show tables", "list schemas", "describe table",
  "inspect table", "run a SQL query", "database schema", or mentions "backoffice", "Aurora", or "postgres".
  Read-only always (transactions forced read-only server-side); defaults to --env test / public schema.
  Production (--env prod-replica, per-market reader host) is available for READ-ONLY SELECT queries when explicitly requested.
  Not for: writing application code or migrations (use /feature); not for: browsing schema-related application code (use /git-repos).
argument-hint: "[database or table name, or SQL query]"
allowed-tools: Bash(aurora-psql *)
disable-model-invocation: true
---

## Connection

Read-only always: only `SELECT` / `WITH ... SELECT` / `EXPLAIN` (no `ANALYZE`) / `SHOW` / catalog
queries, never bypass the `aurora-psql` wrapper, and never assume a database name — `${AURORA_DB_NAME}`
is a per-market template that needs `--market` to resolve, and production names must be resolved
against production.

The full connection and read-only contract is in `@references/connection.md` — follow it exactly.

**Production** (`--env prod-replica`) is live customer data. Use it only when the user has asked for
production in this conversation, and confirm with them before the first production query of a
session. Bound every production query with aggregates or a `LIMIT` (≤ 50 rows).

**Write escalation:** if a task requires a write, say so and point the user at the normal
migration / application path.

## Input Handling

Defaults: `--env test`, schema `public`.

Map `$ARGUMENTS` to a workflow:

| Argument Pattern | Approach |
|------------------|----------|
| (empty) | List databases, schemas, and tables |
| `table_name` or `schema.table_name` | Schema inspection |
| `SELECT ...` or SQL query | Query validation and execution |
| `schema_name` | List tables in schema |
| `database_name` (all lowercase, no dots) | List schemas in database — connect with `--db <database>` |

**Disambiguation:** Bare word: try schema in current DB first; if none, retry as database name.

If `information_schema` returns 0 rows, retry with `--db <resolved app database>`.

Limit output to 50 rows with a truncation notice for larger result sets.

## Cached Overview

If `@references/database-overview.md` exists, present its cached data directly instead of re-querying. The cached file contains databases, schemas, and table names only — no column-level detail. If the user wants column detail for a specific table, proceed to the **Table Schema** workflow.

## Schema Is Truth, Data Is Not (test environment)

This section applies to the **test** connection, where every row is seeded or hand-made test data.
On `prod-replica` the rows are real: report them as production facts, but keep the read-only rules
above and still stop and ask before acting on anything that looks inconsistent.

| Source | Trust | How to report it |
|--------|-------|------------------|
| Structure — columns, types, nullability, constraints, indexes, FKs, enum types | Authoritative | State as fact |
| Rows — values, counts, distributions | Not authoritative | State as an observation from the test environment, with the caveat attached |

When something looks inconsistent — an orphan row, an unexpected NULL, a status no code path writes, a duplicate a constraint should have blocked — **stop and verify with the user**. Do not quietly reconcile it by rewriting the query, widening a filter, or reinterpreting what a column means.

Before asking, gather just enough to make the question answerable:

1. **Quantify it** — `COUNT(*)` of the anomaly against the table total, `GROUP BY` for value distribution, `MIN/MAX` on a timestamp column to date it.
2. **Check the constraint** — query `information_schema.table_constraints` / `pg_constraint` to see whether the DB actually forbids what you found.

Then ask in one message, with those numbers attached: is this expected test data, or a real inconsistency worth pursuing?

Never propose a data fix, backfill, or migration on the strength of a test-environment anomaly alone. Say what would need checking in production instead.

## Related Skills

For planning-time schema research, the `plan` skill spawns the `database-explorer` agent, which reuses this skill's connection pattern and cached overview to return a structured Essential Tables report to `code-architect` agents.
