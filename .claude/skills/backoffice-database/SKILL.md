---
name: backoffice-database
description: >-
  User asks to "query the database", "show tables", "run a SQL query",
  "database schema", or mentions "backoffice" or "postgres".
  Not for: writing application code or migrations (use /feature for implementation, /qred-repo for browsing schema-related code).
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

| Argument Pattern | Intent | Approach |
|------------------|--------|----------|
| (empty) | Overview | List databases, schemas, and tables |
| `table_name` or `schema.table_name` | Table schema | Schema inspection |
| `SELECT ...` or SQL query | Query data | Query validation and execution |
| `schema_name` | Schema tables | List tables in schema |
| `database_name` (all lowercase, no dots) | Database schemas | List schemas in database — connect with `dbname=<database>` |

**Disambiguation:** A bare word like `accounting` could be a schema or database name. Default to schema lookup within the current database first. If no schema is found, retry as a database name.

## Execute

**Overview (no arguments):** If `@references/database-overview.md` exists, present its cached data directly instead of re-querying. The cached file contains databases, schemas, and table names only — no column-level detail. If the user wants column detail for a specific table, proceed to the **Table Schema** workflow. If the user asks to refresh, re-run the queries and update the reference file.

Limit output to 50 rows with a truncation notice for larger result sets (e.g., "Showing 50 of 1,247 rows").

## Error Handling

| Scenario | Response |
|----------|----------|
| 0 rows from information_schema | Retry the query against the resolved app database `dbname` |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Code quality review of query logic or application code |
| `/qred-repo` | Browse repository code related to database schemas |
