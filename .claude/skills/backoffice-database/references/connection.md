# Aurora Connection & Read-Only Contract

Shared by the `backoffice-database` skill and the `database-explorer` agent. Both inline a short
safety floor of their own; this file is the full contract. Follow it exactly.

## Invocation

All queries go through the `aurora-psql` wrapper, which handles authentication, TLS and host
resolution, and refuses anything that is not a read:

```bash
aurora-psql --env <test|prod-replica> [--market <market>] --db <dbname> --query "<SELECT ...>"
```

Defaults: `--env test`, schema `public`.

```bash
# test
aurora-psql --env test --market <market> --db "${AURORA_DB_NAME}" --query "SELECT ..."

# production — read-only, one market per connection
aurora-psql --env prod-replica --market <market> --db <resolved db> --query "SELECT ..."
```

## Environment variables

| Variable | Required | Used for |
|----------|----------|----------|
| `AURORA_DB_NAME` | yes | Per-market database-name **template**, e.g. `qred_{market}_db` |
| `AURORA_HOST` | yes | Test host |
| `AURORA_HOST_PROD` | for `prod-replica` | Production reader host template, with a `{market}` segment |
| `AURORA_SSLMODE` | no | Overrides `sslmode`; see **TLS** below |

`${AURORA_DB_NAME}` is a template, not a finished name: the wrapper substitutes `{market}` from
`--market`. Passing it **without** `--market` is refused rather than silently resolved, so supply
`--market` on test queries too. If the variable is unset, ask the user for the database name — do
not guess one or drop `--db`.

## Resolving the database name

**Never assume the database name.** It does not follow reliably from the market code, and it differs
between environments — at least one market's production database is spelled differently from its
test counterpart, which is why `{market}` substitution is a starting point and not proof.

The cached overview (`.claude/skills/backoffice-database/references/database-overview.md`, untracked)
reflects **test only**. Use it for test; never carry a name from it into production. For
`prod-replica`, resolve the real name against the target environment first:

```bash
aurora-psql --env prod-replica --market <market> --db postgres \
  --query "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname"
```

There is no `allmarkets` host in production — a cross-market answer means one connection per market.

## Read-only enforcement

Reads are enforced by the wrapper, not merely requested of you. It refuses any statement outside the
read set below, plus stacked statements, `EXPLAIN ANALYZE` / `ANALYSE`, and `--env prod`; it sets
`default_transaction_read_only=on` as a **server** parameter via `PGOPTIONS`; it bounds every session
with `statement_timeout=30s`; and for `prod-replica` it asserts the host is an Aurora `cluster-ro`
reader endpoint before connecting, rather than assuming it.

Consequences for how you work:

- Write only `SELECT`, `WITH ... SELECT`, `EXPLAIN` (no `ANALYZE`), `SHOW`, `TABLE`, `VALUES`, and
  `information_schema` / `pg_catalog` queries. Anything else is rejected — do not try to phrase
  around the rejection.
- **Never bypass the wrapper.** Do not call `psql` directly, do not invoke the login helper
  yourself, and do not reconstruct a connection string to work around a refusal.
- If a task genuinely requires a write, it is out of scope: never attempt it in any environment.
  Escalate per the **Write escalation** line in the file that included this one.
- Bound every production query: aggregates over row dumps, and a `LIMIT` (≤ 50 rows) when sampling.
  Production is live customer data — never dump PII columns wholesale, and never copy production row
  values into a PR body, commit message, ticket, or any file written to the repo.
- State which environment and market produced any result you report.

## TLS

The wrapper defaults to `sslmode=verify-full`. Some hosts are CNAME aliases whose certificates name
the underlying RDS endpoint; those fail the handshake until DNS and certificates line up, and
`AURORA_SSLMODE=verify-ca` is the deliberate, per-environment opt-out. If a connection fails on
certificate hostname mismatch, report it as a tool failure and say the override exists — do not set
it yourself.

## Tool failure

If the connection cannot be established — `aurora-psql` is not on `PATH`, authentication fails (an
expired AWS SSO session is the usual cause), the connection times out, a certificate check fails, or
the wrapper reports a missing environment variable — stop and report it per
`.claude/rules/tool-reliability.md`, naming the tool, the failing invocation, and the error.

A refusal from the wrapper's read-only guard is **not** a tool failure: it means the query was
wrong, so fix the query.
