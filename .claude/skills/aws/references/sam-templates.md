# SAM Templates Reference

## Standard Project Structure

```
project-root/
├── template.yaml           # SAM template (source of truth)
├── samconfig.toml           # Deployment configuration
├── src/
│   ├── handlers/
│   │   ├── getUser.ts
│   │   ├── createUser.ts
│   │   └── processOrder.ts
│   ├── shared/
│   │   ├── dynamodb.ts      # DynamoDB client singleton
│   │   ├── errors.ts        # Custom error classes
│   │   └── middleware.ts    # Shared middleware
│   └── types/
│       └── index.ts
├── tests/
│   ├── unit/
│   └── integration/
├── tsconfig.json
├── package.json
└── esbuild.config.ts
```

## SAM Template Skeleton

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: >
  Service description

Globals:
  Function:
    Runtime: nodejs20.x
    Architectures:
      - arm64
    Timeout: 30
    MemorySize: 256
    Environment:
      Variables:
        TABLE_NAME: !Ref DynamoDBTable
        LOG_LEVEL: !Ref LogLevel
    Tracing: Active

Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues:
      - dev
      - staging
      - prod
  LogLevel:
    Type: String
    Default: INFO
    AllowedValues:
      - DEBUG
      - INFO
      - WARN
      - ERROR

Conditions:
  IsProd: !Equals [!Ref Environment, prod]

Resources:
  # Resources go here

Outputs:
  ApiUrl:
    Description: API Gateway endpoint URL
    Value: !Sub 'https://${ServerlessRestApi}.execute-api.${AWS::Region}.amazonaws.com/Prod/'
  TableName:
    Description: DynamoDB table name
    Value: !Ref DynamoDBTable
```

## Resource Configurations

### Lambda + API Gateway

```yaml
GetUserFunction:
  Type: AWS::Serverless::Function
  Properties:
    Handler: src/handlers/getUser.handler
    CodeUri: .
    Description: Get user by ID
    Events:
      GetUser:
        Type: Api
        Properties:
          Path: /users/{userId}
          Method: get
    Policies:
      - DynamoDBReadPolicy:
          TableName: !Ref DynamoDBTable
  Metadata:
    BuildMethod: esbuild
    BuildProperties:
      Minify: true
      Target: es2022
      Sourcemap: true
      EntryPoints:
        - src/handlers/getUser.ts

CreateUserFunction:
  Type: AWS::Serverless::Function
  Properties:
    Handler: src/handlers/createUser.handler
    CodeUri: .
    Description: Create a new user
    Events:
      CreateUser:
        Type: Api
        Properties:
          Path: /users
          Method: post
    Policies:
      - DynamoDBCrudPolicy:
          TableName: !Ref DynamoDBTable
  Metadata:
    BuildMethod: esbuild
    BuildProperties:
      Minify: true
      Target: es2022
      Sourcemap: true
      EntryPoints:
        - src/handlers/createUser.ts
```

### DynamoDB Table

```yaml
DynamoDBTable:
  Type: AWS::DynamoDB::Table
  Properties:
    TableName: !Sub '${AWS::StackName}-table'
    BillingMode: PAY_PER_REQUEST
    AttributeDefinitions:
      - AttributeName: PK
        AttributeType: S
      - AttributeName: SK
        AttributeType: S
      - AttributeName: GSI1PK
        AttributeType: S
      - AttributeName: GSI1SK
        AttributeType: S
    KeySchema:
      - AttributeName: PK
        KeyType: HASH
      - AttributeName: SK
        KeyType: RANGE
    GlobalSecondaryIndexes:
      - IndexName: GSI1
        KeySchema:
          - AttributeName: GSI1PK
            KeyType: HASH
          - AttributeName: GSI1SK
            KeyType: RANGE
        Projection:
          ProjectionType: ALL
    PointInTimeRecoverySpecification:
      PointInTimeRecoveryEnabled: true
    SSESpecification:
      SSEEnabled: true
    Tags:
      - Key: Environment
        Value: !Ref Environment
```

### S3 Bucket

```yaml
UploadBucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: !Sub '${AWS::StackName}-uploads-${AWS::AccountId}'
    BucketEncryption:
      ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: AES256
    PublicAccessBlockConfiguration:
      BlockPublicAcls: true
      BlockPublicPolicy: true
      IgnorePublicAcls: true
      RestrictPublicBuckets: true
    VersioningConfiguration:
      Status: Enabled
    CorsConfiguration:
      CorsRules:
        - AllowedHeaders: ['*']
          AllowedMethods: [GET, PUT]
          AllowedOrigins: ['https://example.com']
          MaxAge: 3600
```

### SQS Queue with Dead Letter Queue

```yaml
ProcessingQueue:
  Type: AWS::SQS::Queue
  Properties:
    QueueName: !Sub '${AWS::StackName}-processing'
    VisibilityTimeout: 180  # 6x Lambda timeout
    RedrivePolicy:
      deadLetterTargetArn: !GetAtt DeadLetterQueue.Arn
      maxReceiveCount: 3

DeadLetterQueue:
  Type: AWS::SQS::Queue
  Properties:
    QueueName: !Sub '${AWS::StackName}-processing-dlq'
    MessageRetentionPeriod: 1209600  # 14 days

ProcessOrderFunction:
  Type: AWS::Serverless::Function
  Properties:
    Handler: src/handlers/processOrder.handler
    CodeUri: .
    Timeout: 30
    Events:
      SQSEvent:
        Type: SQS
        Properties:
          Queue: !GetAtt ProcessingQueue.Arn
          BatchSize: 10
          FunctionResponseTypes:
            - ReportBatchItemFailures
    Policies:
      - DynamoDBCrudPolicy:
          TableName: !Ref DynamoDBTable
```

### SNS Topic

```yaml
NotificationTopic:
  Type: AWS::SNS::Topic
  Properties:
    TopicName: !Sub '${AWS::StackName}-notifications'
    KmsMasterKeyId: alias/aws/sns

NotificationSubscription:
  Type: AWS::SNS::Subscription
  Properties:
    TopicArn: !Ref NotificationTopic
    Protocol: sqs
    Endpoint: !GetAtt ProcessingQueue.Arn
```

### Step Functions

```yaml
OrderStateMachine:
  Type: AWS::Serverless::StateMachine
  Properties:
    DefinitionUri: statemachine/order-workflow.asl.json
    DefinitionSubstitutions:
      ValidateOrderFunctionArn: !GetAtt ValidateOrderFunction.Arn
      ProcessPaymentFunctionArn: !GetAtt ProcessPaymentFunction.Arn
      FulfillOrderFunctionArn: !GetAtt FulfillOrderFunction.Arn
    Policies:
      - LambdaInvokePolicy:
          FunctionName: !Ref ValidateOrderFunction
      - LambdaInvokePolicy:
          FunctionName: !Ref ProcessPaymentFunction
      - LambdaInvokePolicy:
          FunctionName: !Ref FulfillOrderFunction
```

## samconfig.toml

```toml
version = 0.1

[default.global.parameters]
stack_name = "my-service"

[default.build.parameters]
cached = true
parallel = true

[default.deploy.parameters]
capabilities = "CAPABILITY_IAM"
confirm_changeset = true
resolve_s3 = true
region = "us-east-1"
parameter_overrides = "Environment=dev LogLevel=DEBUG"

[staging.deploy.parameters]
stack_name = "my-service-staging"
capabilities = "CAPABILITY_IAM"
confirm_changeset = true
resolve_s3 = true
region = "us-east-1"
parameter_overrides = "Environment=staging LogLevel=INFO"

[prod.deploy.parameters]
stack_name = "my-service-prod"
capabilities = "CAPABILITY_IAM"
confirm_changeset = true
resolve_s3 = true
region = "us-east-1"
parameter_overrides = "Environment=prod LogLevel=WARN"
```

## Deploy Commands

| Command | Description |
|---------|-------------|
| `sam build` | Build the application (compiles TypeScript, bundles) |
| `sam build --cached` | Incremental build (faster) |
| `sam validate` | Validate template syntax |
| `sam local invoke GetUserFunction -e events/get-user.json` | Test locally |
| `sam local start-api` | Start local API Gateway |
| `sam deploy` | Deploy with default config |
| `sam deploy --config-env staging` | Deploy to staging |
| `sam deploy --guided` | Interactive first-time deployment |
| `sam logs -n GetUserFunction --tail` | Tail CloudWatch logs |
| `sam delete` | Delete the stack |

## CloudFormation Intrinsic Functions

| Function | Usage | Example |
|----------|-------|---------|
| `!Ref` | Reference parameter or resource | `!Ref DynamoDBTable` |
| `!Sub` | String substitution | `!Sub '${AWS::StackName}-table'` |
| `!GetAtt` | Get resource attribute | `!GetAtt DynamoDBTable.Arn` |
| `!Join` | Join strings | `!Join ['-', [!Ref Env, 'table']]` |
| `!Select` | Select from list | `!Select [0, !GetAZs '']` |
| `!If` | Conditional value | `!If [IsProd, 512, 256]` |
| `!Equals` | Compare values | `!Equals [!Ref Env, prod]` |
| `!ImportValue` | Cross-stack reference | `!ImportValue SharedVpcId` |
| `!Split` | Split string to list | `!Split [',', !Ref SubnetIds]` |

## SAM Policy Templates

| Policy Template | Grants | Example |
|----------------|--------|---------|
| `DynamoDBReadPolicy` | GetItem, Query, Scan | Read-only Lambda |
| `DynamoDBCrudPolicy` | GetItem, PutItem, UpdateItem, DeleteItem, Query, Scan | CRUD Lambda |
| `DynamoDBStreamReadPolicy` | DescribeStream, GetRecords, GetShardIterator, ListStreams | Stream processor |
| `S3ReadPolicy` | GetObject, ListBucket | Read files |
| `S3CrudPolicy` | GetObject, PutObject, DeleteObject, ListBucket | Full S3 access |
| `SQSPollerPolicy` | ReceiveMessage, DeleteMessage, GetQueueAttributes | SQS consumer |
| `SQSSendMessagePolicy` | SendMessage | SQS producer |
| `SNSPublishMessagePolicy` | Publish | SNS publisher |
| `LambdaInvokePolicy` | InvokeFunction | Lambda-to-Lambda |
| `SSMParameterReadPolicy` | GetParameter, GetParameters | Read SSM params |
| `KMSDecryptPolicy` | Decrypt | Decrypt with KMS |
| `StepFunctionsExecutionPolicy` | StartExecution | Start state machine |
