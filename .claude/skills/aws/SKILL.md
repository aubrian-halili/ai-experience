---
name: aws
description: AWS serverless development guidance including Lambda, API Gateway, DynamoDB, S3, SAM/CloudFormation templates, IAM policies, and security best practices. Use when working with AWS services, serverless architecture, infrastructure as code, or cloud deployment.
allowed-tools: Read, Grep, Glob, Write, Edit, Agent, WebSearch, WebFetch
user-invocable: true
argument-hint: "[service name, pattern question, or leave blank for guidance]"
---

## AWS Serverless Philosophy

1. **Least privilege always** — Every Lambda function, API, and resource gets the minimum IAM permissions required. Start with zero access and add only what's needed.
2. **Design for failure** — Everything fails eventually. Use retries with exponential backoff, dead-letter queues, circuit breakers, and idempotent handlers.
3. **Prefer managed services** — Use DynamoDB over self-managed databases, API Gateway over custom routing, SQS over custom queuing. Let AWS handle the undifferentiated heavy lifting.
4. **Cost awareness** — Serverless costs scale with usage. Optimize cold starts, right-size memory, use reserved capacity for predictable workloads, and monitor with CloudWatch.
5. **Infrastructure as code** — Every resource lives in SAM/CloudFormation templates. No manual console changes. Templates are the source of truth.

## When to Use

### This Skill Is For

- Writing Lambda function handlers (Node.js/TypeScript)
- Configuring API Gateway endpoints and integrations
- Designing DynamoDB table schemas and access patterns
- Writing SAM/CloudFormation templates
- Configuring IAM roles and policies
- Setting up S3 buckets with lifecycle policies
- Debugging Lambda invocation errors and timeouts
- Designing event-driven architectures (SQS, SNS, EventBridge)

### Use a Different Approach When

| Scenario | Use Instead |
|----------|-------------|
| Frontend React code | `/react` |
| Pure TypeScript design | `/typescript` |
| General testing strategy | `/testing` |
| Architecture decision records | `/architecture` |
| Non-AWS security patterns | `/security` |

## Input Classification

| Input Pattern | Classification | Workflow |
|---------------|---------------|----------|
| "Lambda", function name, handler | **Lambda** | Design handler with middleware, error handling, types |
| "API", "Gateway", "endpoint", "REST" | **API Gateway** | Configure routes, validation, CORS, auth |
| "DynamoDB", "table", "query", "GSI" | **DynamoDB** | Design table schema, access patterns, operations |
| "SAM", "CloudFormation", "template", "deploy" | **SAM/CFN** | Write or update IaC templates |
| "IAM", "policy", "role", "permissions" | **IAM** | Design least-privilege policies |
| "S3", "bucket", "upload", "presigned" | **S3** | Configure bucket, lifecycle, access patterns |
| "error", "timeout", "cold start", debug keywords | **Debugging** | Diagnose with CloudWatch, X-Ray, local testing |
| "architecture", "design", "event-driven" | **Architecture** | Design serverless system with event flows |
| File path (`.yaml`, `.yml`, `template.*`) | **Template Analysis** | Read and analyze SAM/CFN template |
| No argument | **Guidance** | Show available workflows and ask for context |

## Process

### 1. Pre-flight

- Find existing SAM/CloudFormation templates (`template.yaml`, `template.yml`, `*.template.*`)
- Check `samconfig.toml` for deployment configuration
- Scan for existing Lambda handlers and their runtime
- Identify shared layers, utilities, and middleware patterns
- Check for existing IAM policies and roles

### 2. Context Analysis

- Map existing resources and their relationships
- Identify event sources and downstream consumers
- Review current IAM permissions for over-privilege
- Check for existing DynamoDB tables and their key schemas
- Note environment variables and configuration patterns

### 3. Design Solution

Apply patterns from reference materials:
- Lambda handlers: @references/serverless-patterns.md
- SAM templates: @references/sam-templates.md
- Security: @references/security.md

Use `ultrathink` for complex architectural decisions. Leverage AWS documentation MCP tools (`aws___search_documentation`, `aws___read_documentation`) for current service limits, quotas, and API specifics.

Key rules:
- Always use TypeScript for Lambda handlers
- Structure handlers with middleware pattern (Middy or manual)
- DynamoDB: design access patterns first, then table schema
- SAM templates: use Globals for shared configuration
- Every resource gets explicit IAM permissions (no `*` actions)

### 4. Security Review

Apply security patterns from @references/security.md:
- Verify IAM follows least privilege
- Check encryption at rest and in transit
- Validate API authentication is configured
- Ensure secrets are in SSM/Secrets Manager, not environment variables
- Review VPC configuration if accessing private resources

### 5. Verification

- Confirm template validates (`sam validate`)
- Check that all resource references resolve
- Verify IAM policies are scoped to specific resources
- Ensure error handling covers all failure modes
- Present changes as template modifications for review

## Safety

**Never deploy or modify AWS resources directly.** All changes are presented as:
- SAM/CloudFormation template modifications
- Code changes to Lambda handlers
- Configuration file updates (`samconfig.toml`, `.env`)

The user controls all deployment actions (`sam deploy`, `aws` CLI commands).

## Output Principles

- **Template-first** — Infrastructure changes are always SAM/CloudFormation, never console instructions.
- **Least privilege** — Every IAM policy is scoped to specific actions and resources.
- **Typed handlers** — Lambda handlers use TypeScript with AWS SDK v3 types.
- **Error resilient** — Every handler includes structured error handling and logging.
- **Cost conscious** — Recommendations include cost implications when relevant.

## Argument Handling

| Argument | Behavior |
|----------|----------|
| `Lambda for processing uploads` | Design S3-triggered Lambda with handler and template |
| `DynamoDB table for orders` | Design single-table schema with access patterns |
| `API Gateway for user service` | Configure REST API with routes, auth, and CORS |
| `SAM template` | Scaffold or review SAM template |
| `IAM policy for Lambda` | Design least-privilege execution role |
| `debug Lambda timeout` | Diagnose timeout with CloudWatch and optimization steps |
| `template.yaml` | Read and analyze the SAM template |
| _(empty)_ | Show available workflows and ask what to build |

## Error Handling

| Scenario | Response |
|----------|----------|
| No SAM/CFN templates found | Offer to scaffold a new project structure |
| Template validation errors | Parse error, explain root cause, provide fix |
| Over-permissive IAM detected | Flag specific violations and provide scoped alternatives |
| Missing environment variables | List required vars and suggest SSM Parameter Store |
| Cold start concerns | Recommend optimization strategies from patterns reference |
| Unsupported runtime | Warn and suggest migration path to supported runtime |

## Related Skills

| Skill | When to Use Instead |
|-------|-------------------|
| `/typescript` | Pure TypeScript types, SDK client design |
| `/security` | Application-level security beyond AWS IAM |
| `/architecture` | System design decisions and ADRs |
| `/testing` | Testing strategies for Lambda and integrations |
| `/diagram` | Visualizing AWS architecture with diagrams |
| `/react` | Frontend that consumes these APIs |
