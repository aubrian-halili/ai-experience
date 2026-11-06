---
name: aws
description: >-
  Read-only AWS inspection through the aws-ro wrapper, on the prod profile by default: CloudWatch
  logs (tail, filter, Logs Insights), metrics and alarms, ECS services, Lambda functions,
  CloudTrail "who changed what", and other describe/list/get reads. Use when the user wants to
  check logs, alarms, or the state of a deployed resource by hand.
  Not for: any change to AWS — restart, scale, deploy, edit (read-only always; point the user at the
  console, CDK, or the pipeline); not for: planning-time research (the aws-explorer agent does that
  non-interactively); not for: database queries (use /backoffice-database).
argument-hint: "[log group, service/function name, alarm, or aws-ro command]"
allowed-tools: Bash(aws-ro *)
disable-model-invocation: true
---

## Access

Read-only always: every call goes through `aws-ro`, never `aws` directly; the profile defaults to
`prod`; and a wrapper refusal (exit `3`) means the request is out of scope, not that another route
should be tried.

Before the first call, read the full access and read-only contract in
`@references/access-and-guardrails.md` and follow it exactly — the allowlist, production data
handling, the **Efficient querying** recipes, and tool failure.

Start each session with `aws-ro sts get-caller-identity` and state the account and role you are
reading from. Switch profile only when the user names another environment (`--profile test`).

**Write escalation:** if a task requires a change, say what the change would be and point the user
at the AWS console, CDK, or the CI/CD pipeline. Never attempt it.

## Input Handling

| Input | Intent | Approach |
|-------|--------|----------|
| (empty) | Orient | `get-caller-identity`, then offer: alarms in `ALARM`, find a log group, list services |
| Log group (`/aws/...`) | Read logs | Layered; enter at Layer 2 |
| Service, function, or app name | Find its resources | Layered; enter at Layer 1 |
| `alarms` | Alarms firing now | `describe-alarms --state-value ALARM` recipe |
| `who changed <resource>` | Audit | `cloudtrail lookup-events` recipe |
| Starts with `aws-ro` or `aws` | Pass-through | Rewrite `aws` as `aws-ro`, run it only if the contract permits; otherwise refuse with one line |
| Error message or request ID | Trace it | Layer 1 to find the group, then Layer 3 with it as the filter pattern |

## Layered Workflow

Each layer ends by presenting its result and offering the next step. Go deeper only when the user
picks a target — never widen the time window or pull more events on your own initiative.

### Layer 1: Locate

Resolve the name to exact resources: log groups by prefix or pattern, the ECS service or Lambda
function, its alarms. If several candidates match, list them and ask which one.

### Layer 2: Status

For the chosen resource, summarize its health without reading logs yet: alarms and their state,
ECS running vs desired count and the last deployment events, Lambda state and last update, and an
error count over the last hour — for Lambda, the `AWS/Lambda` `Errors` sum; for ECS, which has no
built-in error metric, a Logs Insights `stats count(*)` filtered on `/ERROR/` in the service's log
group.

### Layer 3: Logs

Default window: the **last 30 minutes**, capped at 50 events. Use `filter-log-events --max-items 50`
for raw events and Logs Insights `stats` for counts and trends. `logs tail` has no cap flag — use it
only with a narrow `--filter-pattern` (a request ID or exact error string) where the match count is
inherently small.

Present events as a compact timeline (time, level, one-line message); group repeats as
`N× <message template>` rather than printing each:

```text
prod · 123456789012 · eu-west-1 · /aws/lambda/payments-api · last 30m · filter "ERROR"
14:02:11  ERROR  Timeout calling ledger-service (req 7f3a9c…)
14:05:40  ERROR  12× ValidationError: missing field <field>
— 13 events (cap 50, not reached)
```

Ask before widening the window, raising the cap, or reading another log group.

## Related Skills

- `aws-explorer` agent (spawned by `/plan`) — the same read-only contract, run non-interactively for planning or
  debugging research; shares `references/access-and-guardrails.md`.
- `/backoffice-database` — when the question is about persisted data rather than runtime behavior.
- `/git-repos` — to read the service code or CDK stack behind a resource you found here.
