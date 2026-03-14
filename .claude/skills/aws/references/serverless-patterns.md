# Serverless Patterns Reference

## Lambda Handler Patterns

### Standard Handler (TypeScript)

```typescript
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { Logger } from '@aws-lambda-powertools/logger';

const logger = new Logger({ serviceName: 'user-service' });

export const handler = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  logger.info('Processing request', { path: event.path, method: event.httpMethod });

  try {
    const body = JSON.parse(event.body ?? '{}');
    const result = await processRequest(body);

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(result),
    };
  } catch (error) {
    logger.error('Request failed', { error });

    if (error instanceof ValidationError) {
      return {
        statusCode: 400,
        body: JSON.stringify({ message: error.message }),
      };
    }

    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Internal server error' }),
    };
  }
};
```

### Middy Middleware Pattern

```typescript
import middy from '@middy/core';
import httpJsonBodyParser from '@middy/http-json-body-parser';
import httpErrorHandler from '@middy/http-error-handler';
import validator from '@middy/validator';
import { transpileSchema } from '@middy/validator/transpile';

const inputSchema = transpileSchema({
  type: 'object',
  required: ['body'],
  properties: {
    body: {
      type: 'object',
      required: ['name', 'email'],
      properties: {
        name: { type: 'string', minLength: 1 },
        email: { type: 'string', format: 'email' },
      },
    },
  },
});

const baseHandler = async (event: APIGatewayProxyEvent) => {
  const { name, email } = event.body as unknown as CreateUserRequest;
  const user = await createUser({ name, email });
  return { statusCode: 201, body: JSON.stringify(user) };
};

export const handler = middy(baseHandler)
  .use(httpJsonBodyParser())
  .use(validator({ eventSchema: inputSchema }))
  .use(httpErrorHandler());
```

### SQS Batch Handler

```typescript
import { SQSEvent, SQSBatchResponse, SQSBatchItemFailure } from 'aws-lambda';
import { Logger } from '@aws-lambda-powertools/logger';

const logger = new Logger({ serviceName: 'order-processor' });

export const handler = async (event: SQSEvent): Promise<SQSBatchResponse> => {
  const batchItemFailures: SQSBatchItemFailure[] = [];

  for (const record of event.Records) {
    try {
      const order = JSON.parse(record.body);
      logger.info('Processing order', { orderId: order.id });
      await processOrder(order);
    } catch (error) {
      logger.error('Failed to process record', {
        messageId: record.messageId,
        error,
      });
      batchItemFailures.push({ itemIdentifier: record.messageId });
    }
  }

  return { batchItemFailures };
};
```

## Cold Start Optimization

| Technique | Impact | When to Use |
|-----------|--------|-------------|
| Minimize bundle size | High | Always — use tree-shaking and esbuild |
| SDK v3 modular imports | High | Always — import only needed clients |
| Provisioned Concurrency | High | Latency-critical APIs (adds cost) |
| Initialize outside handler | Medium | DB connections, SDK clients |
| ARM64 (Graviton2) | Medium | Always — better price/performance |
| SnapStart (Java only) | High | Java runtimes only |
| Reduce memory (if CPU-bound) | Low | When function is memory-bound |
| Avoid VPC unless needed | Medium | Functions that don't need private resources |

```typescript
// Good: SDK client outside handler (reused across invocations)
const dynamodb = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(dynamodb);

export const handler = async (event: APIGatewayProxyEvent) => {
  // docClient is reused across warm invocations
  const result = await docClient.send(new GetCommand({ ... }));
};
```

## Error Handling

### Custom Error Classes

```typescript
export class AppError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number,
    public readonly code: string,
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 400, 'VALIDATION_ERROR');
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} with id ${id} not found`, 404, 'NOT_FOUND');
  }
}
```

## API Gateway Patterns

### CORS Configuration

```yaml
MyApi:
  Type: AWS::Serverless::Api
  Properties:
    StageName: prod
    Cors:
      AllowMethods: "'GET,POST,PUT,DELETE,OPTIONS'"
      AllowHeaders: "'Content-Type,Authorization'"
      AllowOrigin: "'https://example.com'"
      MaxAge: "'600'"
```

### Lambda Authorizer

```typescript
import {
  APIGatewayTokenAuthorizerEvent,
  APIGatewayAuthorizerResult,
} from 'aws-lambda';

export const handler = async (
  event: APIGatewayTokenAuthorizerEvent,
): Promise<APIGatewayAuthorizerResult> => {
  const token = event.authorizationToken.replace('Bearer ', '');

  try {
    const decoded = await verifyToken(token);
    return generatePolicy(decoded.sub, 'Allow', event.methodArn);
  } catch {
    return generatePolicy('user', 'Deny', event.methodArn);
  }
};

const generatePolicy = (
  principalId: string,
  effect: 'Allow' | 'Deny',
  resource: string,
): APIGatewayAuthorizerResult => ({
  principalId,
  policyDocument: {
    Version: '2012-10-17',
    Statement: [{ Action: 'execute-api:Invoke', Effect: effect, Resource: resource }],
  },
});
```

## DynamoDB Patterns

### Single-Table Design

```
PK                    SK                    Data
USER#<userId>         PROFILE               name, email, createdAt
USER#<userId>         ORDER#<orderId>       total, status, items
ORDER#<orderId>       METADATA              userId, total, status, createdAt
PRODUCT#<productId>   METADATA              name, price, category

GSI1:
GSI1PK                GSI1SK
ORDER#<status>        <createdAt>           For querying orders by status
<category>            PRODUCT#<productId>   For querying products by category
```

### Document Client Operations

```typescript
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import {
  DynamoDBDocumentClient,
  GetCommand,
  PutCommand,
  QueryCommand,
  UpdateCommand,
  DeleteCommand,
} from '@aws-sdk/lib-dynamodb';

const client = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE_NAME = process.env.TABLE_NAME!;

// Get single item
const getUser = async (userId: string) => {
  const { Item } = await client.send(
    new GetCommand({
      TableName: TABLE_NAME,
      Key: { PK: `USER#${userId}`, SK: 'PROFILE' },
    }),
  );
  return Item;
};

// Query items with sort key prefix
const getUserOrders = async (userId: string) => {
  const { Items } = await client.send(
    new QueryCommand({
      TableName: TABLE_NAME,
      KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
      ExpressionAttributeValues: { ':pk': `USER#${userId}`, ':sk': 'ORDER#' },
    }),
  );
  return Items ?? [];
};

// Conditional put (prevent duplicates)
const createUser = async (user: User) => {
  await client.send(
    new PutCommand({
      TableName: TABLE_NAME,
      Item: { PK: `USER#${user.id}`, SK: 'PROFILE', ...user },
      ConditionExpression: 'attribute_not_exists(PK)',
    }),
  );
};

// Update with expression
const updateUserEmail = async (userId: string, email: string) => {
  await client.send(
    new UpdateCommand({
      TableName: TABLE_NAME,
      Key: { PK: `USER#${userId}`, SK: 'PROFILE' },
      UpdateExpression: 'SET email = :email, updatedAt = :now',
      ExpressionAttributeValues: { ':email': email, ':now': new Date().toISOString() },
      ConditionExpression: 'attribute_exists(PK)',
    }),
  );
};
```

### GSI Strategy

| Access Pattern | Base Table / GSI | Key Condition |
|---------------|-----------------|---------------|
| Get user by ID | Base: `PK = USER#<id>, SK = PROFILE` | Exact match |
| Get user's orders | Base: `PK = USER#<id>, SK begins_with ORDER#` | Prefix query |
| Orders by status | GSI1: `GSI1PK = ORDER#<status>` | Exact match, sort by date |
| Products by category | GSI1: `GSI1PK = <category>` | Exact match, sort by name |
| Order by ID | Base: `PK = ORDER#<id>, SK = METADATA` | Exact match |

## S3 Patterns

### Presigned URL Generation

```typescript
import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const s3 = new S3Client({});

export const generateUploadUrl = async (
  key: string,
  contentType: string,
): Promise<string> => {
  const command = new PutObjectCommand({
    Bucket: process.env.BUCKET_NAME!,
    Key: key,
    ContentType: contentType,
  });
  return getSignedUrl(s3, command, { expiresIn: 3600 });
};

export const generateDownloadUrl = async (key: string): Promise<string> => {
  const command = new GetObjectCommand({
    Bucket: process.env.BUCKET_NAME!,
    Key: key,
  });
  return getSignedUrl(s3, command, { expiresIn: 3600 });
};
```
