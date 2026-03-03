# AWS Security Reference

## IAM Least Privilege

### Scoped Policy Example

```yaml
# Bad: overly permissive
Policies:
  - Version: '2012-10-17'
    Statement:
      - Effect: Allow
        Action: 'dynamodb:*'
        Resource: '*'

# Good: scoped to specific actions and resources
Policies:
  - Version: '2012-10-17'
    Statement:
      - Effect: Allow
        Action:
          - dynamodb:GetItem
          - dynamodb:Query
        Resource:
          - !GetAtt UsersTable.Arn
          - !Sub '${UsersTable.Arn}/index/*'
```

### Common IAM Actions by Service

| Service | Read Actions | Write Actions |
|---------|-------------|---------------|
| DynamoDB | `GetItem`, `Query`, `Scan`, `BatchGetItem` | `PutItem`, `UpdateItem`, `DeleteItem`, `BatchWriteItem` |
| S3 | `GetObject`, `ListBucket`, `HeadObject` | `PutObject`, `DeleteObject`, `CopyObject` |
| SQS | `ReceiveMessage`, `GetQueueAttributes` | `SendMessage`, `DeleteMessage`, `PurgeQueue` |
| SNS | `ListSubscriptions`, `GetTopicAttributes` | `Publish`, `Subscribe` |
| SSM | `GetParameter`, `GetParameters`, `GetParametersByPath` | `PutParameter`, `DeleteParameter` |
| Lambda | `GetFunction`, `ListFunctions` | `InvokeFunction`, `UpdateFunctionCode` |
| CloudWatch | `GetMetricData`, `DescribeAlarms` | `PutMetricData`, `PutMetricAlarm` |

### ARN Patterns

```
arn:aws:dynamodb:<region>:<account>:table/<table-name>
arn:aws:dynamodb:<region>:<account>:table/<table-name>/index/<index-name>
arn:aws:s3:::<bucket-name>
arn:aws:s3:::<bucket-name>/<key-prefix>/*
arn:aws:sqs:<region>:<account>:<queue-name>
arn:aws:sns:<region>:<account>:<topic-name>
arn:aws:ssm:<region>:<account>:parameter/<param-path>
arn:aws:lambda:<region>:<account>:function:<function-name>
```

Use `!Sub` with pseudo parameters for dynamic ARNs:

```yaml
Resource: !Sub 'arn:aws:s3:::${UploadBucket}/uploads/${!userId}/*'
```

## Encryption

### At Rest

| Service | Default | Recommended |
|---------|---------|-------------|
| DynamoDB | AWS owned key | Enable SSE with `SSEEnabled: true` (uses AWS managed key) |
| S3 | None | `SSEAlgorithm: AES256` or `aws:kms` for CMK |
| SQS | None | `KmsMasterKeyId: alias/aws/sqs` |
| SNS | None | `KmsMasterKeyId: alias/aws/sns` |
| Lambda env vars | AWS managed | Sufficient for most cases; CMK for regulated data |
| SSM Parameters | Standard: none, SecureString: AWS managed | Use `SecureString` for secrets |

### In Transit

| Concern | Solution |
|---------|----------|
| API Gateway to client | HTTPS enforced by default |
| Lambda to AWS services | AWS SDK uses HTTPS by default |
| S3 bucket policy enforcement | Add `aws:SecureTransport` condition |
| DynamoDB | HTTPS via SDK (default) |

### S3 Enforce HTTPS

```yaml
BucketPolicy:
  Type: AWS::S3::BucketPolicy
  Properties:
    Bucket: !Ref UploadBucket
    PolicyDocument:
      Statement:
        - Sid: DenyInsecureTransport
          Effect: Deny
          Principal: '*'
          Action: 's3:*'
          Resource:
            - !GetAtt UploadBucket.Arn
            - !Sub '${UploadBucket.Arn}/*'
          Condition:
            Bool:
              'aws:SecureTransport': 'false'
```

## API Authentication Patterns

| Pattern | Use When | Complexity |
|---------|----------|------------|
| **IAM Auth** | Service-to-service calls, internal APIs | Low |
| **Cognito Authorizer** | User-facing apps with sign-up/sign-in | Medium |
| **Lambda Authorizer** | Custom auth logic, third-party tokens (JWT) | Medium |
| **API Key** | Rate limiting, third-party consumers (NOT for auth alone) | Low |

### Cognito Authorizer (SAM)

```yaml
MyApi:
  Type: AWS::Serverless::Api
  Properties:
    StageName: prod
    Auth:
      DefaultAuthorizer: CognitoAuthorizer
      Authorizers:
        CognitoAuthorizer:
          UserPoolArn: !GetAtt UserPool.Arn

UserPool:
  Type: AWS::Cognito::UserPool
  Properties:
    UserPoolName: !Sub '${AWS::StackName}-users'
    AutoVerifiedAttributes:
      - email
    Policies:
      PasswordPolicy:
        MinimumLength: 12
        RequireUppercase: true
        RequireLowercase: true
        RequireNumbers: true
        RequireSymbols: true
```

### Lambda Authorizer (SAM)

```yaml
MyApi:
  Type: AWS::Serverless::Api
  Properties:
    StageName: prod
    Auth:
      DefaultAuthorizer: TokenAuthorizer
      Authorizers:
        TokenAuthorizer:
          FunctionArn: !GetAtt AuthorizerFunction.Arn
          Identity:
            Header: Authorization
            ReauthorizeEvery: 300

AuthorizerFunction:
  Type: AWS::Serverless::Function
  Properties:
    Handler: src/handlers/authorizer.handler
    CodeUri: .
    Timeout: 5
    Policies:
      - SSMParameterReadPolicy:
          ParameterName: !Sub '${AWS::StackName}/jwt-secret'
```

## Secrets Management

### SSM Parameter Store

```typescript
import { SSMClient, GetParameterCommand } from '@aws-sdk/client-ssm';

const ssm = new SSMClient({});

// Cache parameters outside handler for warm invocation reuse
let cachedSecret: string | null = null;

const getSecret = async (name: string): Promise<string> => {
  if (cachedSecret) return cachedSecret;

  const { Parameter } = await ssm.send(
    new GetParameterCommand({ Name: name, WithDecryption: true }),
  );

  cachedSecret = Parameter?.Value ?? '';
  return cachedSecret;
};
```

### SAM Parameter Store Configuration

```yaml
Parameters:
  JwtSecretParam:
    Type: AWS::SSM::Parameter::Value<String>
    Default: /my-service/jwt-secret

GetUserFunction:
  Type: AWS::Serverless::Function
  Properties:
    Environment:
      Variables:
        JWT_SECRET_PARAM: /my-service/jwt-secret
    Policies:
      - SSMParameterReadPolicy:
          ParameterName: my-service/jwt-secret
```

### Secrets Manager (for rotation)

```yaml
DatabaseSecret:
  Type: AWS::SecretsManager::Secret
  Properties:
    Name: !Sub '${AWS::StackName}/db-credentials'
    GenerateSecretString:
      SecretStringTemplate: '{"username": "admin"}'
      GenerateStringKey: password
      PasswordLength: 32
      ExcludeCharacters: '"@/\'
```

### Anti-Patterns

| Anti-Pattern | Risk | Fix |
|-------------|------|-----|
| Secrets in environment variables directly | Visible in console, logs, `printenv` | Use SSM Parameter Store with `WithDecryption` |
| Secrets in code or config files | Committed to version control | Use SSM or Secrets Manager |
| Hardcoded API keys | Leaked via git history | Use SSM SecureString |
| Shared IAM keys across services | Blast radius on compromise | Per-function execution roles |
| Wildcard resource ARNs (`*`) | Access to all resources | Scope to specific ARNs |

## Serverless Security Checklist

### IAM
- [ ] Each Lambda has its own execution role
- [ ] Policies use specific actions (no wildcards)
- [ ] Policies use specific resource ARNs
- [ ] No inline policies on Lambda roles (use SAM policy templates)

### API Gateway
- [ ] Authentication configured (Cognito, Lambda Authorizer, or IAM)
- [ ] Request validation enabled
- [ ] CORS restricted to specific origins
- [ ] Rate limiting / throttling configured
- [ ] WAF attached for public APIs (if applicable)

### Data
- [ ] DynamoDB SSE enabled
- [ ] S3 encryption enabled (AES256 or KMS)
- [ ] S3 public access blocked
- [ ] S3 HTTPS enforced via bucket policy
- [ ] SQS/SNS encrypted with KMS

### Secrets
- [ ] No secrets in environment variables or code
- [ ] Secrets stored in SSM SecureString or Secrets Manager
- [ ] Lambda has minimal SSM read permissions (specific parameter paths)
- [ ] Rotation configured for database credentials

### Logging & Monitoring
- [ ] X-Ray tracing enabled (`Tracing: Active`)
- [ ] CloudWatch alarms for errors and throttles
- [ ] No sensitive data logged (PII, tokens, passwords)
- [ ] DLQ configured for async invocations
