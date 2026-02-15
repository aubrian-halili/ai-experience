---
name: typescript
description: Use when the user asks about "TypeScript", "TS types", "type error", "generics", "type inference", mentions "tsconfig", "strict mode", "type narrowing", or needs TypeScript-specific guidance, type definitions, and advanced typing patterns.
argument-hint: "[code, type, or TypeScript question]"
---

Provide TypeScript-specific guidance including type definitions, generics, type inference, compiler configuration, and advanced typing patterns.

## When to Use

### This Skill Is For

- Writing type definitions and interfaces
- Fixing TypeScript compiler errors
- Designing generic types and utilities
- Configuring tsconfig.json
- Type narrowing and guards
- Advanced typing patterns
- Migration from JavaScript to TypeScript

### Use a Different Approach When

- General code review → use `/review`
- Architecture decisions → use `/architecture`
- Testing TypeScript code → use `/testing`

## Process

### 1. Understand the Context

- What TypeScript version?
- What's the tsconfig strictness level?
- What framework/library context?

### 2. Analyze the Problem

- Is it a type definition issue?
- Is it a compiler configuration issue?
- Is it a type inference issue?

### 3. Provide Solution

- Type definitions with explanations
- Configuration recommendations
- Code examples showing correct usage

## Response Format

```markdown
## TypeScript Solution

**Problem**: [Brief description]
**TypeScript Version**: [X.X]
**Category**: [Types | Generics | Config | Error Fix]

---

### Solution

[Explanation of the approach]

```typescript
// Type definition or code solution
```

### Why This Works

[Explanation of the TypeScript concepts involved]

### Alternative Approaches

[Other valid approaches with trade-offs]
```

## Common Type Patterns

### Basic Types

```typescript
// Primitives
type Primitive = string | number | boolean | null | undefined;

// Objects
interface User {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

// Arrays
type StringArray = string[];
type UserArray = Array<User>;

// Tuples
type Coordinate = [number, number];
type NamedCoordinate = [x: number, y: number];

// Enums (prefer const objects)
const Status = {
  Active: 'active',
  Inactive: 'inactive',
  Pending: 'pending',
} as const;
type Status = typeof Status[keyof typeof Status];
```

### Utility Types

```typescript
// Partial - all properties optional
type PartialUser = Partial<User>;

// Required - all properties required
type RequiredUser = Required<User>;

// Pick - select specific properties
type UserName = Pick<User, 'id' | 'name'>;

// Omit - exclude specific properties
type UserWithoutEmail = Omit<User, 'email'>;

// Record - object with specific key/value types
type UserMap = Record<string, User>;

// ReadOnly - immutable properties
type ImmutableUser = Readonly<User>;

// NonNullable - exclude null and undefined
type DefinitelyString = NonNullable<string | null>;

// ReturnType - infer function return type
type FunctionReturn = ReturnType<typeof someFunction>;

// Parameters - infer function parameters
type FunctionParams = Parameters<typeof someFunction>;
```

### Generic Patterns

```typescript
// Basic generic
function identity<T>(value: T): T {
  return value;
}

// Constrained generic
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// Generic with default
function createArray<T = string>(length: number, value: T): T[] {
  return Array(length).fill(value);
}

// Generic interface
interface Repository<T> {
  findById(id: string): Promise<T | null>;
  findAll(): Promise<T[]>;
  create(data: Omit<T, 'id'>): Promise<T>;
  update(id: string, data: Partial<T>): Promise<T>;
  delete(id: string): Promise<void>;
}

// Generic class
class ApiClient<T> {
  constructor(private baseUrl: string) {}

  async get(id: string): Promise<T> {
    const response = await fetch(`${this.baseUrl}/${id}`);
    return response.json();
  }
}
```

### Type Narrowing

```typescript
// Type guards
function isString(value: unknown): value is string {
  return typeof value === 'string';
}

function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value
  );
}

// Discriminated unions
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

function handleResult<T>(result: Result<T>) {
  if (result.success) {
    // TypeScript knows result.data exists
    console.log(result.data);
  } else {
    // TypeScript knows result.error exists
    console.error(result.error);
  }
}

// Assertion functions
function assertDefined<T>(value: T | null | undefined): asserts value is T {
  if (value === null || value === undefined) {
    throw new Error('Value must be defined');
  }
}
```

### Advanced Patterns

```typescript
// Mapped types
type Nullable<T> = { [K in keyof T]: T[K] | null };
type Getters<T> = { [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K] };

// Conditional types
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T;
type ArrayElement<T> = T extends (infer E)[] ? E : never;

// Template literal types
type EventName = `on${Capitalize<string>}`;
type HTTPMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type Endpoint = `/${string}`;
type Route = `${HTTPMethod} ${Endpoint}`;

// Recursive types
type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K];
};

type JSONValue =
  | string
  | number
  | boolean
  | null
  | JSONValue[]
  | { [key: string]: JSONValue };

// Branded types (nominal typing)
type UserId = string & { readonly __brand: unique symbol };
type OrderId = string & { readonly __brand: unique symbol };

function createUserId(id: string): UserId {
  return id as UserId;
}
```

### Error Handling Patterns

```typescript
// Result type
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

function err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

// Safe parsing
function safeParse<T>(
  json: string,
  validator: (data: unknown) => data is T
): Result<T, Error> {
  try {
    const data = JSON.parse(json);
    if (validator(data)) {
      return ok(data);
    }
    return err(new Error('Validation failed'));
  } catch (e) {
    return err(e instanceof Error ? e : new Error(String(e)));
  }
}
```

## tsconfig.json Best Practices

```json
{
  "compilerOptions": {
    // Strict mode (recommended)
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "useUnknownInCatchVariables": true,

    // Additional checks
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,

    // Module resolution
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "esModuleInterop": true,
    "resolveJsonModule": true,

    // Output
    "target": "ES2022",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,

    // Paths
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## Common Error Solutions

### Error: Type 'X' is not assignable to type 'Y'

```typescript
// Problem
const value: string = 123; // Error

// Solutions:
// 1. Fix the type
const value: number = 123;

// 2. Use type assertion (if you're sure)
const value = 123 as unknown as string;

// 3. Use union type
const value: string | number = 123;
```

### Error: Object is possibly 'undefined'

```typescript
// Problem
function process(user?: User) {
  console.log(user.name); // Error
}

// Solutions:
// 1. Optional chaining
console.log(user?.name);

// 2. Guard clause
if (!user) return;
console.log(user.name);

// 3. Non-null assertion (if you're sure)
console.log(user!.name);

// 4. Default value
function process(user: User = defaultUser) {
  console.log(user.name);
}
```

### Error: Property 'X' does not exist on type 'Y'

```typescript
// Problem
interface User { name: string; }
const user: User = { name: 'John', age: 30 }; // Error

// Solutions:
// 1. Extend the interface
interface User { name: string; age: number; }

// 2. Use index signature
interface User {
  name: string;
  [key: string]: unknown;
}

// 3. Type assertion
const user = { name: 'John', age: 30 } as User & { age: number };
```

## Declaration File Patterns

```typescript
// For a module without types
declare module 'untyped-module' {
  export function doSomething(input: string): string;
  export default class Client {
    constructor(options: ClientOptions);
    request(method: string, path: string): Promise<Response>;
  }
}

// Global augmentation
declare global {
  interface Window {
    myCustomProperty: string;
  }
}

// Ambient declarations
declare const MY_GLOBAL: string;
declare function myGlobalFunction(): void;
```

## Error Handling

| Scenario | Response |
|----------|----------|
| Complex type error | Break down the error, explain each part |
| Generic confusion | Start with concrete types, then generalize |
| tsconfig questions | Explain impact of each option |
| Type inference issues | Show explicit types to clarify |

## Related Skills

| Skill | When to Use Instead |
|-------|---------------------|
| `/review` | Code review including TypeScript quality |
| `/clean-code` | Refactoring TypeScript code |
| `/testing` | Writing tests for TypeScript code |
| `/patterns` | Design patterns in TypeScript |
