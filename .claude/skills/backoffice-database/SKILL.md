---
name: backoffice-database
description: >-
  Read-only queries and schema inspection for the backoffice Aurora PostgreSQL databases:
  list databases/schemas/tables, describe a table, or run a SELECT. Defaults to --env test /
  public schema; production (--env prod-replica) only when explicitly requested, read-only.
  Not for: writing application code or migrations (use /feature); not for: browsing
  schema-related application code (use /git-repos).
argument-hint: "[database or table name, or SQL query]"
allowed-tools: Bash(aurora-psql *)
disable-model-invocation: true
---

## Connection

Read-only always: only `SELECT` / `WITH ... SELECT` / `EXPLAIN` (no `ANALYZE`) / `SHOW` / catalog
queries, never bypass the `aurora-psql` wrapper, and never assume a database name — `${AURORA_DB_NAME}`
is a per-market template that needs `--market` to resolve, and production names must be resolved
against production.

Before the first query, read the full connection and read-only contract in
`@references/connection.md` and follow it exactly.

**Production** (`--env prod-replica`) is live customer data. Use it only when the user has asked for
production in this conversation, confirm with them before the first production query of a session,
and bound every production query with aggregates or a `LIMIT` (≤ 50 rows).

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
| Bare word (no dots) | Try as a schema in the current DB and list its tables; if none, retry as a database (`--db <word>`) and list its schemas |

If `information_schema` returns 0 rows, retry with `--db <resolved app database>`.

Limit output to 50 rows with a truncation notice for larger result sets.

## Cached Overview

For `--env test`, if `@references/database-overview.md` exists, present its cached data directly
instead of re-querying. It lists databases, schemas, and tables only; for column detail, run
**Schema inspection**. It reflects test only — never use it to answer a production request.

## Schema Is Truth, Data Is Not (test environment)

This section applies to the **test** connection, where every row is seeded or hand-made test data.
On `prod-replica` the rows are real: report them as production facts, but still stop and ask before
acting on anything that looks inconsistent.

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

- `database-explorer` agent (spawned by `/plan`) — reuses this skill's `references/` for planning-time schema research.
