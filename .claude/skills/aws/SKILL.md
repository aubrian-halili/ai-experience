---
name: aws
description: >-
  User asks about AWS services (Lambda, DynamoDB, S3, SQS), SAM/CloudFormation,
  IAM policies, or mentions "serverless" or "AWS".
  Not for: general architecture (use /architecture), TypeScript without AWS context
  (use /typescript).
allowed-tools: Read, Grep, Glob, Write, Edit, Agent, WebSearch, WebFetch
argument-hint: "[service name, pattern question, or leave blank for guidance]"
---

## AWS Serverless Philosophy

- **Least privilege always** — Every Lambda function, API, and resource gets the minimum IAM permissions required. Start with zero access and add only what's needed.
- **Design for failure** — Everything fails eventually. Use retries with exponential backoff, dead-letter queues, circuit breakers, and idempotent handlers.
- **Prefer managed services** — Use DynamoDB over self-managed databases, API Gateway over custom routing, SQS over custom queuing. Let AWS handle the undifferentiated heavy lifting.
- **Cost awareness** — Serverless costs scale with usage. Optimize cold starts, right-size memory, use reserved capacity for predictable workloads, and monitor with CloudWatch.
- **Infrastructure as code** — Every resource lives in SAM/CloudFormation templates. No manual console changes. Templates are the source of truth.

## Input Handling

Classify `$ARGUMENTS` to determine the serverless workflow scope:

| Input | Intent | Approach |
|-------|--------|----------|
| (none) | Determine target service or question | Ask user to specify service, resource, or question |
| Service name or description (e.g., `Lambda for uploads`, `DynamoDB orders table`) | Design for specific service | Create handler, template, schema, or policy from references |
| File path (e.g., `template.yaml`, `src/handlers/orders.ts`) | Analyze existing code or template | Read file, evaluate patterns, security, and structure |
| Action + target (e.g., `deploy user-api`, `add GSI to orders table`) | Modify existing infrastructure | Apply workflow for template, IAM, or config changes |
| Bug/error description (e.g., `Lambda timeout`, `API Gateway 502`) | Diagnose and fix issue | Root cause analysis with CloudWatch, X-Ray, local testing |
| Concept/pattern question (e.g., `single-table design`, `event-driven patterns`) | Explain pattern or concept | Pattern lookup and guidance from references |

## Process

### 1. Pre-flight

- Classify serverless workflow scope from `$ARGUMENTS` using the Input Handling table
- Find existing SAM/CloudFormation templates (`template.yaml`, `template.yml`, `*.template.*`)
- Check `samconfig.toml` for deployment configuration
- Scan for existing Lambda handlers and their runtime
- Identify shared layers, utilities, and middleware patterns
- Check for existing IAM policies and roles

**Stop conditions:**
- Referenced file or template not found → report missing path, ask user to verify
- Request is outside AWS serverless scope (e.g., EC2 instances, container orchestration) → note limitation, suggest appropriate tools
- No SAM/CloudFormation templates and no handler code found → offer to scaffold a new project structure

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

Leverage AWS documentation MCP tools (`aws___search_documentation`, `aws___read_documentation`) for current service limits, quotas, and API specifics.

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
- **Production-ready handlers** — Lambda handlers use TypeScript with AWS SDK v3 types, structured error handling, and CloudWatch-compatible logging.
- **Cost conscious** — Recommendations include cost implications when relevant.

## Error Handling

| Scenario | Response |
|----------|----------|
| No SAM/CFN templates found | Offer to scaffold a new project structure |
| Template validation errors | Parse error, explain root cause, provide fix |
| Over-permissive IAM detected | Flag specific violations and provide scoped alternatives |
| Missing environment variables | List required vars and suggest SSM Parameter Store |
| Cold start concerns | Recommend optimization strategies from patterns reference |
| Unsupported runtime | Warn and suggest migration path to supported runtime |

Never silently skip security checks or assume IAM permissions are correct—surface all findings and coverage limitations explicitly.

## Related Skills

| Skill | When to Use Instead |
|-------|-------------------|
| `/typescript` | Pure TypeScript types, SDK client design |
| `/security` | Application-level security beyond AWS IAM |
| `/architecture` | System design decisions and ADRs |
| `/testing` | Testing strategies for Lambda and integrations |
| `/diagram` | Visualizing AWS architecture with diagrams |
| `/explore` | Understand existing infrastructure code first |
| `/docs` | Write runbooks or deployment documentation |
