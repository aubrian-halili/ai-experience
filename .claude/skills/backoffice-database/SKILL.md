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

Explore PostgreSQL database schemas and run read-only queries against the backoffice Aurora cluster. All operations are strictly read-only.

## Database Philosophy

- **Read-only only** — Never execute INSERT, UPDATE, DELETE, DROP, ALTER, TRUNCATE, CREATE, or any DDL/DML. Only SELECT, WITH, SHOW, EXPLAIN, and DESCRIBE are permitted. Enforced server-side via `default_transaction_read_only=on`

## Connection

Use psql with an explicit `dbname` for all queries:

```bash
PGPASSWORD=$(${AURORA_LOGIN_SCRIPT} auth DB_USER=${AURORA_DB_USER} ENV=test MARKET=allmarkets ENGINE=pgadmin) \
  psql "host=${AURORA_HOST} port=5432 dbname=${AURORA_DB_NAME} user=${AURORA_DB_USER} \
  sslmode=verify-ca sslrootcert=${AURORA_SSL_CERT} connect_timeout=10" \
  --no-psqlrc --set=default_transaction_read_only=on -c "<query>"
```

## Input Handling

Parse `$ARGUMENTS` to understand what the user wants:

| Argument Pattern | Intent | Approach |
|------------------|--------|----------|
| (empty) | Overview | Steps 1–3; list databases, schemas, and tables |
| `table_name` or `schema.table_name` | Table schema | Steps 1–3; emphasis on schema inspection |
| `SELECT ...` or SQL query | Query data | Steps 1–3; emphasis on query validation and execution |
| `schema_name` | Schema tables | Steps 1–3; list tables in schema |
| `database_name` (all lowercase, no dots) | Database schemas | Steps 1–3; list schemas in database |

**Disambiguation:** A bare word like `accounting` could be a schema or database name. Default to schema lookup within the current database first. If no schema is found, retry as a database name. If neither matches, report not found and list available options.

## Process

### 1. Pre-flight

- Run the psql pattern with the resolved `dbname` and query `SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname;` to verify connectivity and list databases
- Set default database: `qred_se_db`
- Set default schema: `public`
- Parse `$ARGUMENTS` and map to the appropriate workflow (Overview, Table Schema, Query Data, Schema Tables, or Database Schemas) using the Input Handling table

### 2. Execute

All queries use the psql pattern from Connection above with the resolved `dbname`.

**Overview (no arguments)**

If `@references/database-overview.md` exists, present its cached data directly instead of re-querying. The cached file contains databases, schemas, and table names only — no column-level detail. If the user wants column detail for a specific table, proceed to the **Table Schema** workflow. If the user asks to refresh, re-run the queries below and update the reference file.

1. Show all available databases:
   ```sql
   SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname;
   ```
2. Show schemas in the default database:
   ```sql
   SELECT schema_name FROM information_schema.schemata ORDER BY schema_name;
   ```
3. Show tables:
   ```sql
   SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;
   ```

**Table Schema**
1. Parse table name (extract schema and table from `schema.table` or assume `public` schema)
2. Run:
   ```sql
   SELECT column_name, data_type, is_nullable, column_default
   FROM information_schema.columns
   WHERE table_schema = '<schema>' AND table_name = '<table>'
   ORDER BY ordinal_position;
   ```
3. Present columns, types, constraints, and indexes

**SQL Query**
1. Validate query is read-only:
   - Must start with SELECT, WITH, SHOW, EXPLAIN, or DESCRIBE
   - Must not contain semicolons followed by additional statements (no multi-statement queries — e.g., `SELECT 1; DROP TABLE foo` is rejected)
   - The server enforces read-only via `default_transaction_read_only=on` as a safety net, but reject ambiguous queries client-side before running
2. Run the validated SQL

**Schema Tables**
```sql
SELECT table_name FROM information_schema.tables WHERE table_schema = '<schema>' ORDER BY table_name;
```

**Database Schemas** — use `dbname=<database>`:
```sql
SELECT schema_name FROM information_schema.schemata ORDER BY schema_name;
```

### 3. Verify Results

- If empty result set → Note "Query returned 0 rows" explicitly; if querying `information_schema`, check that the correct `dbname` was used
- If entity not found (database, schema, or table) → Fall through to Error Handling

## Output Principles

- **Context first** — Always show which database and schema you're querying before presenting results
- **Structured presentation** — Use markdown tables for schemas (Column Name | Data Type | Nullable | Constraints) and query results (proper headers); use bullet lists for databases, schemas, and table names; always include row counts and indicate if results are truncated
- **Bounded results** — For large result sets, show first 50 rows with clear truncation notice (e.g., "Showing 50 of 1,247 rows")
- **Next steps** — Suggest related queries or tables to explore based on results; if exploring schema that maps to application models, reference relevant code files

## Error Handling

| Scenario | Response |
|----------|----------|
| Auth command fails | "Aurora login failed. Check aurora-login configuration and credentials." |
| psql not found | "psql not found. Ensure PostgreSQL client tools are installed." |
| 0 rows from information_schema | "Got 0 rows — this query must target a specific app database. Retrying with psql against the resolved `dbname`." |
| Database not found | List known databases from catalog and ask user to specify |
| Schema not found | List available schemas in the database |
| Table not found | List available tables in the schema |
| Write operation attempted | "Only read-only queries are allowed. Use SELECT, WITH, SHOW, or EXPLAIN." |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Code quality review of query logic or application code |
| `/qred-repo` | Browse repository code related to database schemas |
