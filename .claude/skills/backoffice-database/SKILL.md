---
name: backoffice-database
description: >-
  User asks to "query the database", "show tables", "run a SQL query",
  "database schema", or mentions "backoffice" or "postgres".
  Not for: database architecture or schema design (use /architecture).
argument-hint: "[database or table name, or SQL query]"
disable-model-invocation: true
allowed-tools: mcp__qred-postgres__list_databases, mcp__qred-postgres__list_schemas, mcp__qred-postgres__list_tables_in_schema, mcp__qred-postgres__read_schema_of_table, mcp__qred-postgres__query
---

Explore PostgreSQL database schemas and run read-only queries using the qred-postgres MCP server. All operations are strictly read-only.

## Database Philosophy

- **Read-only only** — Never execute INSERT, UPDATE, DELETE, DROP, ALTER, TRUNCATE, CREATE, or any DDL/DML. Only SELECT, WITH, SHOW, EXPLAIN, and DESCRIBE are permitted
- **No credential exposure** — Never include connection strings, passwords, or auth tokens in output
- **Bounded results** — Always LIMIT queries; cap at 50 rows unless the user explicitly requests more
- **Explicit scope** — State the target database and schema before every operation
- **Progressive exploration** — Start with high-level overview (databases → schemas → tables) before diving into detailed queries; guide users toward discovering structure naturally

## When to Use

### This Skill Is For

- Discovering available databases, schemas, and tables in PostgreSQL
- Inspecting table structures (columns, types, constraints)
- Running read-only SQL queries to explore data
- Understanding database schema without leaving the conversation

### Use a Different Approach When

- Investigating application code → use `/explore`
- Visualizing database relationships as ERD → use `/diagram`
- Making database changes → this skill is read-only, use appropriate database tools

## Input Classification

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

- Call `mcp__qred-postgres__list_databases` to verify the MCP server is reachable
- Set default database: `qred_se_db`
- Set default schema: `public`
- Parse `$ARGUMENTS` and map to the appropriate workflow (Overview, Table Schema, Query Data, Schema Tables, or Database Schemas) using the Input Classification table

**Stop condition:**
- MCP server unreachable → "The qred-postgres MCP server is not configured. Install and configure it to use this skill."

**Default routing:** No arguments provided → proceed with Overview workflow (list databases, schemas, and tables)

### 2. Execute

Based on intent, use the appropriate MCP tool:

**Overview (no arguments)**
1. Call `mcp__qred-postgres__list_databases` to show all available databases
2. Call `mcp__qred-postgres__list_schemas` with `qred_se_db` to show schemas in the default database
3. Call `mcp__qred-postgres__list_tables_in_schema` with `qred_se_db` and `public` to show tables

**Table Schema**
1. Parse table name (extract schema and table from `schema.table` or assume `public` schema)
2. Call `mcp__qred-postgres__read_schema_of_table` with URI format: `schema_name.table_name`
3. Present columns, types, constraints, and indexes

**SQL Query**
1. Validate query is read-only (must start with SELECT, WITH, SHOW, EXPLAIN, or DESCRIBE)
2. Call `mcp__qred-postgres__query` with the SQL and default database
3. Present results in a clear table format
4. If query fails, show error and suggest corrections

**Schema Tables**
1. Call `mcp__qred-postgres__list_tables_in_schema` with database and schema name
2. Present list of tables

**Database Schemas**
1. Call `mcp__qred-postgres__list_schemas` with the specified database name
2. Present list of schemas

### 3. Verify Results

- Confirm the MCP call returned data successfully
- If empty result set → Note "Query returned 0 rows" explicitly
- If entity not found (database, schema, or table) → Fall through to Error Handling
- Present results following Output Principles

## Output Principles

- **Context first** — Always show which database and schema you're querying before presenting results
- **Structured presentation** — Use markdown tables for schemas (Column Name | Data Type | Nullable | Constraints) and query results (proper headers); use bullet lists for databases, schemas, and table names; always include row counts and indicate if results are truncated
- **Bounded results** — For large result sets, show first 50 rows with clear truncation notice (e.g., "Showing 50 of 1,247 rows")
- **Next steps** — Suggest related queries or tables to explore based on results; if exploring schema that maps to application models, reference relevant code files

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | List all databases, show schemas and tables in `qred_se_db` |
| `users` | Show schema for `public.users` table |
| `public.orders` | Show schema for `public.orders` table |
| `SELECT * FROM users LIMIT 10` | Query first 10 users |
| `accounting` | List tables in `accounting` schema |
| `other_db` | List schemas in `other_db` database |


## Error Handling

| Scenario | Response |
|----------|----------|
| MCP tools unavailable | "The qred-postgres MCP server is not configured. Install and configure it to use this skill." |
| Database not found | List available databases and ask user to specify |
| Schema not found | List available schemas in the database |
| Table not found | List available tables in the schema |
| Query syntax error | Show the error message and suggest corrections |
| Write operation attempted | "Only read-only queries are allowed. Use SELECT, WITH, SHOW, or EXPLAIN." |
| Authentication error | "PostgreSQL connection failed. Check MCP server configuration and credentials." |
| Connection timeout | "Database connection timeout. Check server availability and network." |

Never execute a write operation or expose credentials — if a query appears to modify data, refuse it and explain why.

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/explore` | To investigate application code, not database |
| `/diagram` | To visualize database relationships as ERD |
| `/architecture` | To design or evaluate database architecture decisions |
| `/docs` | To document database schema or data models |
| `/testing` | Write integration tests for database queries |
