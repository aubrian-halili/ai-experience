---
name: backoffice-database
description: Use when the user asks to "explore the database", "show tables", "describe table", "query the database", "database schema", mentions "backoffice db", "PostgreSQL", "postgres tables", or needs to inspect database structure and run read-only queries.
argument-hint: "[database or table name, or SQL query]"
allowed-tools: mcp__qred-postgres__list_databases, mcp__qred-postgres__list_schemas, mcp__qred-postgres__list_tables_in_schema, mcp__qred-postgres__read_schema_of_table, mcp__qred-postgres__query
---

Explore PostgreSQL database schemas and run read-only queries using the qred-postgres MCP server. All operations are strictly read-only.

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

## Safety Principles

- **Read-only only** — Never execute INSERT, UPDATE, DELETE, DROP, ALTER, TRUNCATE, CREATE, or any DDL/DML. Only SELECT, WITH, SHOW, EXPLAIN, and DESCRIBE are permitted
- **No credential exposure** — Never include connection strings, passwords, or auth tokens in output
- **Bounded results** — Always LIMIT queries; cap at 50 rows unless the user explicitly requests more
- **Explicit scope** — State the target database and schema before every operation

## Process

### 1. Pre-flight

**Check MCP availability:**
- Call `mcp__qred-postgres__list_databases` to verify the MCP server is reachable
- MCP available → Proceed to step 2
- MCP unavailable → Stop with error: "The qred-postgres MCP server is not configured. Install and configure it to use this skill."

**Set defaults:**
- **Default database**: `qred_se_db`
- **Default schema**: `public`
- Parse `$ARGUMENTS` to override if a different database or schema is specified

### 2. Determine Intent

Parse `$ARGUMENTS` to understand what the user wants:

| Argument Pattern | Intent | Action |
|-----------------|--------|--------|
| (empty) | Overview | List databases and default database schemas |
| `table_name` or `schema.table_name` | Table schema | Read table structure with columns and types |
| `SELECT ...` or SQL query | Query data | Execute read-only query |
| `schema_name` | Schema tables | List tables in that schema |
| `database_name` (all lowercase, no dots) | Database schemas | List schemas in that database |

### 3. Execute

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
1. Validate query is read-only (starts with SELECT, WITH, SHOW, EXPLAIN, etc.)
2. Call `mcp__qred-postgres__query` with the SQL and default database
3. Present results in a clear table format
4. If query fails, show error and suggest corrections

**Schema Tables**
1. Call `mcp__qred-postgres__list_tables_in_schema` with database and schema name
2. Present list of tables

**Database Schemas**
1. Call `mcp__qred-postgres__list_schemas` with the specified database name
2. Present list of schemas

### 4. Verify Results

- Confirm the MCP call returned data successfully
- If empty result set → Note "Query returned 0 rows" explicitly
- If entity not found (database, schema, or table) → Fall through to Error Handling
- Present results following Output Principles

## Output Principles

- **Context first** — Always show which database and schema you're querying
- **Structured presentation** — Use markdown tables for structured data (schemas: Column Name | Data Type | Nullable | Default | Constraints; query results: proper column headers)
- **Lists** — Use bullet points for databases, schemas, and table lists
- **Row counts** — Always include row counts for query results
- **Row limits** — For large result sets, show first 50 rows and indicate if truncated
- **Next steps** — Suggest related queries or tables to explore based on results
- **File references** — If exploring schema that maps to application models, reference relevant code files

## Argument Handling

| Argument | Behavior |
|----------|----------|
| (none) | List all databases, show schemas and tables in `qred_se_db` |
| `users` | Show schema for `public.users` table |
| `public.orders` | Show schema for `public.orders` table |
| `SELECT * FROM users LIMIT 10` | Query first 10 users |
| `accounting` | List tables in `accounting` schema |
| `other_db` | List schemas in `other_db` database |

**Disambiguation:** A bare word like `accounting` could be a schema name or a database name. Default to schema lookup within the current database first. If no schema is found, retry as a database name. If neither matches, report not found and list available schemas and databases.

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

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/explore` | To investigate application code, not database |
| `/diagram` | To visualize database relationships as ERD |
