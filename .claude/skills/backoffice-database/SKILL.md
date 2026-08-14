---
name: backoffice-database
description: >-
  User asks to "query the database", "show tables", "list schemas", "describe table",
  "inspect table", "run a SQL query", "database schema", or mentions "backoffice", "Aurora", or "postgres".
  Read-only by default (transactions forced read-only); defaults to the qred_se_db / public schema.
  Not for: writing application code or migrations (use /feature); not for: browsing schema-related application code (use /git-repos).
argument-hint: "[database or table name, or SQL query]"
allowed-tools: Bash(PGPASSWORD=*)
disable-model-invocation: true
---

## Connection

Use psql with an explicit `dbname` for all queries:

```bash
PGPASSWORD=$(${AURORA_LOGIN_SCRIPT} auth DB_USER=${AURORA_DB_USER} ENV=test MARKET=allmarkets ENGINE=pgadmin) \
  psql "host=${AURORA_HOST} port=5432 dbname=${AURORA_DB_NAME} user=${AURORA_DB_USER} \
  sslmode=verify-ca sslrootcert=${AURORA_SSL_CERT} connect_timeout=10" \
  --no-psqlrc --set=default_transaction_read_only=on -c "<query>"
```

## Input Handling

Defaults: database `qred_se_db`, schema `public`.

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

## Schema Is Truth, Data Is Not

The connection targets `ENV=test`, so every row is seeded or hand-made test data.

| Source | Trust | How to report it |
|--------|-------|------------------|
| Structure — columns, types, nullability, constraints, indexes, FKs, enum types | Authoritative | State as fact |
| Rows — values, counts, distributions | Not authoritative | State as an observation from the test environment, with the caveat attached |

When something looks inconsistent — an orphan row, an unexpected NULL, a status no code path writes, a duplicate a constraint should have blocked — **stop and verify with the user**. Do not assume the data is correct, and do not quietly reconcile it by rewriting the query, widening a filter, or reinterpreting what a column means.

Before asking, gather just enough to make the question answerable:

1. **Quantify it** — `COUNT(*)` of the anomaly against the table total, `GROUP BY` for value distribution, `MIN/MAX` on a timestamp column to date it. One stray row reads very differently from 90% of the table.
2. **Check the constraint** — query `information_schema.table_constraints` / `pg_constraint` to see whether the DB actually forbids what you found. If the schema permits it, it is not a violation.

Then ask the user in one message: what you found, the numbers, whether the schema forbids it, and the question itself — is this expected test data, or a real inconsistency worth pursuing? Wait for the answer before drawing any conclusion from those rows.

Never propose a data fix, backfill, or migration on the strength of a test-environment anomaly alone. Say what would need checking in production instead.

## Related

For planning-time schema research, the `plan` skill spawns the `database-explorer` agent, which reuses this skill's connection pattern and cached overview to return a structured Essential Tables report to `code-architect` agents.
