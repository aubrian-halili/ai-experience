---
name: backoffice-database
description: >-
  User asks to "query the database", "show tables", "list schemas", "describe table",
  "inspect table", "run a SQL query", "database schema", or mentions "backoffice", "Aurora", or "postgres".
  Read-only always (transactions forced read-only); defaults to the ENV=test default database / public schema.
  Production (ENV=prod-replica, per-market host) is available for READ-ONLY SELECT queries when explicitly requested.
  Not for: writing application code or migrations (use /feature); not for: browsing schema-related application code (use /git-repos).
argument-hint: "[database or table name, or SQL query]"
allowed-tools: Bash(aurora-psql *)
disable-model-invocation: true
---

## Connection

All queries go through the `aurora-psql` wrapper, which handles authentication, TLS and host
resolution, and refuses anything that is not a read:

```bash
aurora-psql --env <test|prod-replica> [--market <market>] --db <dbname> --query "<SELECT ...>"
```

Defaults: `--env test`, `--db ${AURORA_DB_NAME}`, schema `public`. `--market` is required for
`prod-replica` and ignored for `test`.

```bash
# test (default)
aurora-psql --env test --db ${AURORA_DB_NAME} --query "SELECT ..."

# production — read-only, one market per connection
aurora-psql --env prod-replica --market <market> --db <resolved db> --query "SELECT ..."
```

**Never assume the database name.** It does not follow reliably from the market code, and it
differs between environments — at least one market's production database is spelled differently
from its test counterpart. The cached overview
(`.claude/skills/backoffice-database/references/database-overview.md`, untracked) reflects **test
only**; do not carry a name from it into production. Resolve the real name against the target
environment first:

```bash
aurora-psql --env prod-replica --market <market> --db postgres \
  --query "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname"
```

There is no `allmarkets` host in production — a cross-market answer means one connection per market.

### Read-Only Enforcement

Reads are enforced by the wrapper, not merely requested of you. It refuses non-`SELECT` statements,
stacked statements, `EXPLAIN ANALYZE`, and `--env prod`; it pins
`default_transaction_read_only=on`; and in production it connects to an Aurora reader endpoint that
rejects writes outright.

Consequences for how you work:

- Write only `SELECT`, `WITH ... SELECT`, `EXPLAIN` (no `ANALYZE`), `SHOW`, and
  `information_schema` / `pg_catalog` queries. Anything else will be rejected — do not try to phrase
  around the rejection.
- **Never bypass the wrapper.** Do not call `psql` directly, do not invoke the login helper
  yourself, and do not reconstruct a connection string to work around a refusal.
- If a task genuinely requires a write, it is out of scope here: say so and point the user at the normal
  migration / application path.
- Bound every production query: aggregates over row dumps, and a `LIMIT` (≤ 50 rows) when sampling.
  Production is live customer data — never dump PII columns wholesale.
- State which environment and market produced any result you report.

## Input Handling

Defaults: database `${AURORA_DB_NAME}`, schema `public`.

Map `$ARGUMENTS` to a workflow:

| Argument Pattern | Approach |
|------------------|----------|
| (empty) | List databases, schemas, and tables |
| `table_name` or `schema.table_name` | Schema inspection |
| `SELECT ...` or SQL query | Query validation and execution |
| `schema_name` | List tables in schema |
| `database_name` (all lowercase, no dots) | List schemas in database — connect with `dbname=<database>` |

**Disambiguation:** Bare word: try schema in current DB first; if none, retry as database name.

If `information_schema` returns 0 rows, retry against the resolved app database `dbname`.

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

## Related

For planning-time schema research, the `plan` skill spawns the `database-explorer` agent, which reuses this skill's connection pattern and cached overview to return a structured Essential Tables report to `code-architect` agents.
