---
name: backoffice-database
description: >-
  User asks to "query the database", "show tables", "run a SQL query",
  "database schema", or mentions "backoffice" or "postgres".
  Not for: database architecture or schema design (use /architecture).
argument-hint: "[database or table name, or SQL query]"
allowed-tools: Bash
disable-model-invocation: true
---

Explore PostgreSQL database schemas and run read-only queries using the backoffice-postgres.sh CLI wrapper. All operations are strictly read-only.

## Database Philosophy

- **Read-only only** — Never execute INSERT, UPDATE, DELETE, DROP, ALTER, TRUNCATE, CREATE, or any DDL/DML. Only SELECT, WITH, SHOW, EXPLAIN, and DESCRIBE are permitted
- **No credential exposure** — Never include connection strings, passwords, or auth tokens in output
- **Bounded results** — Always LIMIT queries; cap at 50 rows unless the user explicitly requests more
- **Explicit scope** — State the target database and schema before every operation
- **Progressive exploration** — Start with high-level overview (databases → schemas → tables) before diving into detailed queries; guide users toward discovering structure naturally

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

- Run `~/aurora-login/backoffice-postgres.sh "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname;"` to verify the script is reachable
- Set default database: `qred_se_db`
- Set default schema: `public`
- Parse `$ARGUMENTS` and map to the appropriate workflow (Overview, Table Schema, Query Data, Schema Tables, or Database Schemas) using the Input Handling table

**Stop condition:**
- Script not found or not executable → "backoffice-postgres.sh not found or not executable. Ensure ~/aurora-login/backoffice-postgres.sh exists and has execute permissions (`chmod +x ~/aurora-login/backoffice-postgres.sh`)."


### 2. Execute

Based on intent, run the appropriate query via `~/aurora-login/backoffice-postgres.sh`:

**Overview (no arguments)**
1. Run `~/aurora-login/backoffice-postgres.sh "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname;"` to show all available databases
2. Run `~/aurora-login/backoffice-postgres.sh "SELECT schema_name FROM information_schema.schemata ORDER BY schema_name;"` to show schemas in the default database
3. Run `~/aurora-login/backoffice-postgres.sh "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"` to show tables

**Table Schema**
1. Parse table name (extract schema and table from `schema.table` or assume `public` schema)
2. Run `~/aurora-login/backoffice-postgres.sh "SELECT column_name, data_type, is_nullable, column_default FROM information_schema.columns WHERE table_schema = '<schema>' AND table_name = '<table>' ORDER BY ordinal_position;"`
3. Present columns, types, constraints, and indexes

**SQL Query**
1. Validate query is read-only (must start with SELECT, WITH, SHOW, EXPLAIN, or DESCRIBE)
2. Run `~/aurora-login/backoffice-postgres.sh "<validated SQL>"`
3. Present results in a clear table format
4. If query fails, show error and suggest corrections

**Schema Tables**
1. Run `~/aurora-login/backoffice-postgres.sh "SELECT table_name FROM information_schema.tables WHERE table_schema = '<schema>' ORDER BY table_name;"`
2. Present list of tables

**Database Schemas**
1. Run `~/aurora-login/backoffice-postgres.sh "SELECT schema_name FROM information_schema.schemata ORDER BY schema_name;"`
2. Present list of schemas

### 3. Verify Results

- Confirm the script call returned data successfully
- If empty result set → Note "Query returned 0 rows" explicitly
- If entity not found (database, schema, or table) → Fall through to Error Handling
- Present results following Output Principles

## Output Principles

- **Context first** — Always show which database and schema you're querying before presenting results
- **Structured presentation** — Use markdown tables for schemas (Column Name | Data Type | Nullable | Constraints) and query results (proper headers); use bullet lists for databases, schemas, and table names; always include row counts and indicate if results are truncated
- **Bounded results** — For large result sets, show first 50 rows with clear truncation notice (e.g., "Showing 50 of 1,247 rows")
- **Next steps** — Suggest related queries or tables to explore based on results; if exploring schema that maps to application models, reference relevant code files

## Error Handling

| Scenario | Response |
|----------|----------|
| Script unavailable | "backoffice-postgres.sh not found or not executable. Ensure ~/aurora-login/backoffice-postgres.sh exists and has execute permissions." |
| Database not found | List available databases and ask user to specify |
| Schema not found | List available schemas in the database |
| Table not found | List available tables in the schema |
| Query syntax error | Show the error message and suggest corrections |
| Write operation attempted | "Only read-only queries are allowed. Use SELECT, WITH, SHOW, or EXPLAIN." |
| Authentication error | "PostgreSQL connection failed. Check backoffice-postgres.sh configuration and credentials." |
| Connection timeout | "Database connection timeout. Check server availability and network." |

Never execute a write operation or expose credentials — if a query appears to modify data, refuse it and explain why.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/explore` | To investigate application code, not database |
| `/architecture` | To design, evaluate, or visualize database architecture |
| `/testing` | Write integration tests for database queries |
