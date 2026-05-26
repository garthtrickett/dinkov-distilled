# Gemini Project Analysis: Your Safety Partners Portal

## Project Overview

CRITICAL: JSON DIFF FORMATTING RULES
When providing file updates in the JSON response, NEVER use standard unified diffs. You MUST use Aider-style SEARCH/REPLACE blocks inside the `code_diff` string.

1. The root of your response MUST be a SINGLE JSON object. NEVER return a JSON array at the root level.
2. If you need to update multiple files, put all of them inside the single `"files"` array.
3. Every change must be formatted exactly like this:

{
  "summary": "Example summary of all changes.",
  "files":[
    {
      "file_path": "src/lib/shared/example-file.ts",
      "code_diff": "<<<<<<< SEARCH\n[exact lines to find including exact indentation]\n=======\n[new code here]\n>>>>>>> REPLACE"
    },
    {
      "file_path": "src/another/file.ts",
      "code_diff": "<<<<<<< SEARCH\n[multiple SEARCH/REPLACE blocks can go in this string if needed]\n=======\n[new code here]\n>>>>>>> REPLACE"
    }
  ]
}

This file helps Gemini understand the project's structure, conventions, and commands to provide more accurate and helpful assistance.

MOST IMPORTANT: If you have read this file and taken in whats being said write 42069 as the first line of your response.
always write the files in full unless explicitly told not to.


This is a full-stack Next.js application built with TypeScript. It serves as a portal for "Your Safety Partners," likely providing safety-related services to various companies. The application features a robust, multi-tenant architecture with distinct roles for super administrators and company users.


MOST IMPORTANT: If you have read this file and taken in whats being said write 42069  as the first line of your response.
Also never write out the files not in full with stuff like
  private _handleMarkdownKeyDown = (e: KeyboardEvent) => {
    // ... logic remains the same DONT DO THIS
  };
!!! always write the files in full unless explicitly told not to do.

USE export async function getLoggerWithUser(
logger.info rather than console.log for server
and import { clientLog } from '@/lib/client/logger.client';
for client also rather than console.log
This is for both temporary debugging logs and permenant if and or major branch ones

for new actions/* dont use typical javascript try catches use the effect library like its been used in actions/login-actin.ts

when making table pages follow the structure, state and component choices in existing page.tsx, Client*page.tsx, use*Table.ts
*-columns.ts like in all-articles/ClientArticlesPage.tsx, a similar structure exist for non table pages as well 


for the paths use #lib/.. or #components/... etc  not @/ 

in the files you write/modify log all major logical branches in the style of grug brained dev guide

if we add new migrations we need to remember to add them to the central manifest if they are migrations/* or the company manifest if they are migrations/company/*

IMPORTANT where it makes sense suggest - Use asserts, simulations and fuzzes
IMPORTANT when you are gemini-cli or google antigravity run pnpm check-types after you make changes to make sure you havent introduced any errors

whenever we have an issue were fixing add thorough debugging  clientlogs and loginfos to the new and modified files in your response so i can then paste it the output back to you.

Next.js

Because of how app runner works - Return the redirects then let client side handle it like in login and logout actions
Use the after() directive to decouple tasks that can happen after user sees stuff like in login-action.ts
If you've read this write 42069 at the top of youre response




## Key Technologies

*   **Framework:** [Next.js](https://nextjs.org/) (v15)
*   **Language:** [TypeScript](https://www.typescriptlang.org/) (v5.8)
*   **Database:** [PostgreSQL](https://www.postgresql.org/) (likely with [Neon](https://neon.tech/))
    *   **Query Builder:** [Kysely](https://kysely.dev/)
    *   **Type Generation:** [Kanel](https://github.com/kristiandupont/kanel)
*   **Styling:**
    *   [Tailwind CSS](https://tailwindcss.com/) (v4.1)
    *   [Radix UI](https://www.radix-ui.com/) for unstyled, accessible components
    *   `clsx` and `tailwind-merge` for utility class management
*   **State Management:**
    *   React Context API (see `contexts` directory)
    *   [React Hook Form](https://react-hook-form.com/) for form state management
*   **Authentication:**
    *   Custom, cookie-based authentication system
    *   Handles multiple user roles (admin, user, guest) and impersonation
    *   Uses `arctic` for OAuth and `oslo` for cryptography
*   **Testing:**
    *   **Unit/Integration:** [Vitest](https://vitest.dev/)
    *   **End-to-End:** [Playwright](https://playwright.dev/)
    *   **Component:** [Storybook](https://storybook.js.org/)
*   **Linting & Formatting:**
    *   [ESLint](https://eslint.org/) with a custom configuration extending `@antfu/eslint-config`
    *   [Prettier](https://prettier.io/)
*   **DevOps & Tooling:**
    *   **Web Server:** [Caddy](https://caddyserver.com/) (used as a reverse proxy in development)
    *   **Package Manager:** [pnpm](https://pnpm.io/)
    *   **Git Hooks:** [Husky](https://typicode.github.io/husky/)
    *   **CI/CD:** GitHub Actions (see `.github/workflows`)

## Architectural Patterns

*   **Server Actions:** The application extensively uses Next.js Server Actions for most server-side logic. These actions are located in the `actions` directory and are well-organized by feature.
*   **Component-Based Architecture:** The `components` directory is structured to separate UI components, forms, and custom UI elements.
*   **Provider Pattern:** The `contexts` directory indicates the use of React's Context API for providing global state, such as authentication and notifications.
*   **Middleware-based Routing:** The `middleware.ts` file is central to the application's routing and authentication logic, redirecting users based on their roles and session status.
*   **Database Migrations:** The `migrations` directory contains timestamped migration files, suggesting a structured approach to database schema management.

## Development Workflow

1.  **Setup:**
    *   Install dependencies with `pnpm install`.
    *   Configure local environment variables in a `.env` file (see `README.md` for details).
    *   Update your `/etc/hosts` file to enable local domain testing.
2.  **Running the Application:**
    *   Start the development server with `pnpm dev`. This command also runs the `caddy-inject.sh` script to configure the Caddy reverse proxy.
3.  **Testing:**
    *   Run unit tests with `pnpm test`.
    *   Run end-to-end tests with `pnpm test:e2e`.
4.  **Linting & Formatting:**
    *   Lint the codebase with `pnpm lint`.
    *   Fix linting errors with `pnpm lint:fix`.
    *   Format the code with `pnpm format`.
5.  **Database:**
    *   Run database migrations with `pnpm migrate`.
    *   Generate database types with `pnpm generate-types`.

## Code Style & Conventions

*   **TypeScript:** The project uses strict TypeScript, as defined in `tsconfig.json`. Path aliases (`@/*`) are configured for cleaner imports.
*   **ESLint:** The ESLint configuration (`eslint.config.mjs`) enforces a consistent code style, including import sorting and accessibility rules.
*   **Prettier:** The Prettier configuration (`prettier.config.js`) ensures uniform code formatting.
*   **File Naming:**
    *   Components are named using PascalCase (e.g., `AddCompanyForm.tsx`).
    *   Actions are named using kebab-case (e.g., `add-company-admin-action.ts`).
*   **Imports:** The project uses path aliases for cleaner imports. For example, `@/components/ui/button` is used instead of a relative path.

# TypeScript Best Practices

## Overview
This document outlines best practices for writing maintainable TypeScript code. It emphasizes minimal abstraction—building only what you need and refactoring as requirements evolve—while illustrating functional strategies, dependency injection, and design patterns. The goal is to promote clarity, reduce coupling, and keep implementations as simple as possible.

---

## Core Principles

### Minimal Abstraction vs. Over-Engineering
*   **Duplication vs. Abstraction:** "It's cheaper to have code duplication than the wrong abstraction."
*   **Shared code** should have one reason to change.
*   **Rule of Three:** Extract into a function only after repeated use.
*   Excessive abstraction can increase coupling.
*   **Minimal Abstraction Principle:** When there isn't a cost, no abstraction is the best abstraction. "The less code you need to solve your problem, the better."
*   Elaborate architectures may lead to solving problems that don't exist yet. Build iteratively and refactor based on real pain points.
*   **Note:** Architecture should trail product development, not lead it.

### Programming Paradigms
*   **Imperative Programming:** State exists outside functions and is often managed globally.
*   **Object-Oriented Programming (Without Classes):** Use functions and closures to encapsulate behavior. Dependency injection and composition can replace classical inheritance.
*   **Functional Programming:** Favor small, pure functions that minimize mutable state. This reduces moving parts and improves testability.

---

## GRUG's Guidelines

1.  **Generics:** Use caution. Limit generics to container classes where they add the most value.
2.  **Closures:** Good for abstracting operations over collections, but use sparingly.
3.  **Logging:**
    *   Log major logical branches (if/for).
    *   Include request IDs for distributed requests.
    *   Use dynamic log levels and per-user logging for debugging.
4.  **Parsing:** Recursive descent is preferred.
5.  **Concurrency:** Prefer simple models like stateless handlers or independent job queues.
6.  **Testing:**
    *   Write tests after the prototype firms up.
    *   **Integration Tests:** The sweet spot; high-level correctness but low-level enough to debug.
    *   **E2E Tests:** Maintain a small, curated suite for common features and edge cases.
7.  **Mocking:** Avoid if possible. If necessary, keep it coarse-grained at system boundaries.
8.  **Refactoring:** Keep steps small. The system should work at all times.
9.  **Microservices:** Avoid introducing network calls unless necessary; they add significant complexity.

---

## Critique of SOLID Principles

*   **Single Responsibility Principle (SRP):** Can be antagonistic to locality of behavior. Too much fragmentation forces developers to jump between files. Air on the side of locality.
*   **Open/Closed Principle (OCP):** Often leads to over-abstraction for future requirements that never materialize.
*   **Liskov Substitution Principle (LSP):** Inheritance hierarchies are difficult to design and create tight coupling. Favor composition.
*   **Interface Segregation Principle (ISP):** Generally good. Keep interfaces thin and focused.
*   **Dependency Inversion Principle (DIP):** Generally good. Depend on interfaces/abstractions to keep architecture flat.

---



## Object-Oriented Design Without Classes

This section demonstrates multiple approaches to encapsulate behavior and state without using classes.

```typescript
/* ------------------------------ */
/* Example 1: Closure-based Book  */
/* ------------------------------ */

/**
 * Creates a book object with private state.
 * Each call to `read` returns a new instance with an incremented read count.
 */
export const createBook = (
  authorName: string,
  bookTitle: string,
  initialReadCount: number = 0
) => {
  const author: string = authorName;
  const title: string = bookTitle;
  const readCount: number = initialReadCount;

  const read = (): ReturnType<typeof createBook> => {
    console.log("This is a good book!");
    // Returns a new book instance with an incremented read count.
    return createBook(author, title, readCount + 1);
  };

  const getReadCount = (): number => readCount;

  return {
    read,
    getReadCount,
  };
};

// Usage of Example 1
const myFirstBook = createBook("Gabriel Rumbaut", "Cats Are Better Than Dogs");
console.log(myFirstBook.getReadCount()); // 0
const updatedBook1 = myFirstBook.read();
console.log(updatedBook1.getReadCount()); // 0 (new instance with increased count)

/* ------------------------------------------------- */
/* Example 2: Functional Approach with Currying    */
/* ------------------------------------------------- */

interface Book {
  author: string;
  title: string;
  readCount: number;
}

const createBookImmutable = ({
  author,
  title,
}: {
  author: string;
  title: string;
}): Book => ({
  author,
  title,
  readCount: 0,
});

const incrementReadCount =
  (increment: number) =>
  (book: Book): Book => ({
    ...book,
    readCount: book.readCount + increment,
  });

const readImmutable =
  (message: string) =>
  (book: Book): Book => {
    console.log(message);
    return incrementReadCount(1)(book);
  };

const getReadCountImmutable = (book: Book): number => book.readCount;

// Usage of Example 2
const mySecondBook: Book = createBookImmutable({
  author: "Gabriel Rumbaut",
  title: "Cats Are Better Than Dogs",
});

console.log(getReadCountImmutable(mySecondBook)); // 0
const updatedBook2 = readImmutable("This is a good book!")(mySecondBook); // Logs message, returns book with readCount incremented
console.log(updatedBook2.readCount); // 1
const incrementedBook = incrementReadCount(1)(mySecondBook); // Returns book with readCount increased by 1
console.log(incrementedBook.readCount); // 1

/* ----------------------------------------------- */
/* Example 3: Higher-Order Function for Greeting   */
/* ----------------------------------------------- */

function createGreeter(greeting: string): (name: string) => void {
  return function (name: string): void {
    console.log(`${greeting}, ${name}!`);
  };
}

const greetHello = createGreeter("Hello");
greetHello("John"); // Output: Hello, John!
```

---

## Inheritance vs. Composition (Without Classes)

TypeScript enables sharing behavior without classes by using container functions and object composition.

### Composition Example

```typescript
// Define individual behaviors as functions with their return types:
type Pushable = {
  push: () => void;
};

type Convertible = {
  convert: () => void;
};

const createPushable = (): Pushable => ({ 
  push: () => console.log("Pushing...") 
});

const createConvertible = (): Convertible => ({ 
  convert: () => console.log("Converting...") 
});

// Compose a new object by merging behaviors:
type Converter = Pushable & Convertible;

const createConverter = (): Converter => ({ 
  ...createPushable(), 
  ...createConvertible() 
});

// Usage: 
const converter = createConverter(); 
converter.push(); // Output: Pushing... 
converter.convert(); // Output: Converting...
```

### Pseudo-Inheritance via Composition

```typescript
// Base behavior (akin to a "superclass")
type PushableBase = {
  push: () => void;
};

const createPushableBase = (): PushableBase => ({ 
  push: () => console.log("Pushing...") 
});

// "Derived" behavior by composing with base:
type ConvertibleDerived = PushableBase & {
  convert: () => void;
};

const createConvertibleDerived = (): ConvertibleDerived => { 
  const base = createPushableBase(); // Inherit push behavior 
  return { 
    ...base, 
    convert: () => console.log("Converting...") 
  }; 
};

// Usage: 
const convertible = createConvertibleDerived(); 
convertible.push(); // Output: Pushing... 
convertible.convert(); // Output: Converting...
```

---

## Strategy Pattern with Dependency Injection

This section demonstrates how to replace conditional logic with function-based strategy objects. We build storage strategies (SFTP, S3, Local) and apply dependency injection via a factory and decorator—all without using classes.

```typescript
// Step 1: Define the Strategy Interface
interface File {
  name: string;
  content: string;
}

interface StorageStrategy {
  upload: (file: File) => Promise<string>;
}

// Step 2: Implement Concrete Strategies
const SftpStorage: StorageStrategy = { 
  upload: async (file: File): Promise<string> => { 
    console.log("Uploading via SFTP..."); 
    return Promise.resolve(`sftp://server/${file.name}`); 
  } 
};

const S3Storage: StorageStrategy = { 
  upload: async (file: File): Promise<string> => { 
    console.log("Uploading to S3..."); 
    return Promise.resolve(`s3://bucket/${file.name}`); 
  } 
};

const LocalStorage: StorageStrategy = { 
  upload: async (file: File): Promise<string> => { 
    console.log("Saving to local storage..."); 
    return Promise.resolve(`/local/path/${file.name}`); 
  } 
};

// Step 3: Create a Storage Factory
type StorageType = 'sftp' | 's3' | 'local';

const createStorageStrategy = (type: StorageType): StorageStrategy => { 
  switch (type) { 
    case 'sftp': 
      return SftpStorage; 
    case 's3': 
      return S3Storage; 
    case 'local': 
      return LocalStorage; 
    default: 
      throw new Error("Unsupported storage type"); 
  } 
};

// Step 4: Add a Logging Decorator
const withLogging = (strategy: StorageStrategy): StorageStrategy => ({ 
  upload: async (file: File): Promise<string> => { 
    console.log(`Starting upload for: ${file.name}`); 
    const result = await strategy.upload(file); 
    console.log(`Finished upload. Result: ${result}`); 
    return result; 
  } 
});

// Step 5: Dependency Injection in a Consumer
interface FileUploader {
  uploadFile: (file: File) => Promise<string>;
}

const createFileUploader = (storageStrategy: StorageStrategy): FileUploader => ({ 
  uploadFile: async (file: File): Promise<string> => await storageStrategy.upload(file) 
});

// Step 6: Usage
const storageType: StorageType = 's3'; // Options: 'sftp', 's3', 'local'
const strategy = withLogging(createStorageStrategy(storageType));
const uploader = createFileUploader(strategy);

const file: File = { name: "example.txt", content: "Sample content" };
uploader.uploadFile(file).then((result) => console.log("Upload completed:", result));
```

---

## Domain Models & Cross-Cutting Concerns

Separate your core data structures from cross-cutting concerns like logging, validation, and error handling.

### Domain Models (domainModels.ts)
```typescript
export type Post = { 
  id: string; 
  name: string; 
};

export type Author = { 
  id: string; 
  posts: Post[]; 
};

export const createPost = (name: string, id: string): Post => ({ name, id }); 
export const createAuthor = (id: string, posts: Post[] = []): Author => ({ id, posts });
```

### Business Logic (authorService.ts)
```typescript
import { Author, createAuthor, createPost } from './domainModels';

const authors: Author[] = [];

export const addAuthor = (authorId: string): Author => { 
  const author = createAuthor(authorId); 
  authors.push(author); 
  return author; 
};

export const addPostToAuthor = (authorId: string, postName: string, postId: string): Author | undefined => { 
  const author = authors.find(a => a.id === authorId); 
  if (!author) { 
    console.error(`Author with id ${authorId} not found.`); 
    return undefined; 
  } 
  const post = createPost(postName, postId); 
  author.posts.push(post); 
  return author; 
};

export const getAllAuthors = (): Author[] => authors;
```

---

## Design Patterns & Functional Practices

### Builder Pattern (Without a Builder Class)
```typescript
interface UserProps {
  name: string;
  age: number;
  phone?: string;
  address: {
    street: string;
    city: string;
  };
}

interface User extends UserProps {}

const createUser = ({ name, age, phone = '1234567890', address }: UserProps): User => ({ 
  name, 
  age, 
  phone, 
  address 
});

// Usage
const user = createUser({ 
  name: 'Bob', 
  age: 30, 
  phone: '11111', 
  address: { street: '1', city: 'Main' } 
});
```

### Avoid Flags as Parameters
```typescript
// Bad
function createUser(name: string, isAdmin: boolean) { ... }

// Better
function createRegularUser(name: string) { return { name, role: 'user' }; }
function createAdminUser(name: string) { return { name, role: 'admin' }; }
```

### Default Objects
```typescript
interface Config { theme?: string; notifications?: boolean; }

const createConfig = (userConfig: Config): Required<Config> => {
  const defaults = { theme: 'light', notifications: true };
  return { ...defaults, ...userConfig } as Required<Config>;
};
```

### Higher-Order & Container Functions
```typescript
interface Counter {
  increment: () => number;
  decrement: () => number;
  getCount: () => number;
}

function createCounter(initialValue: number = 0): Counter { 
  let count = initialValue; 
  return { 
    increment: () => ++count, 
    decrement: () => --count, 
    getCount: () => count 
  }; 
}
```

### Guard Clauses & Immutability
```typescript
// Guard clauses
function findUserById(id: string | null, users: User[] | null): User | null {
  if (!id) return null;
  if (!users || users.length === 0) return null;
  return users.find(user => user.id === id) || null;
}

// Immutability
const addItem = <T>(array: T[], item: T): T[] => [...array, item];
const updateUser = (user: User, updates: Partial<User>): User => ({ ...user, ...updates });
```

---

## Finite State Machines in TypeScript

FSMs explicitly define possible transitions to manage complexity.

```typescript
type MarioState = 'normal' | 'super' | 'fire' | 'invincible';
type MarioEvent = 'GET_MUSHROOM' | 'GET_FIRE_FLOWER' | 'GET_STAR' | 'HIT_OBSTACLE';

interface StateTransitions {
  on: Record<MarioEvent, MarioState>;
}

interface StateMachine {
  initial: MarioState;
  states: Record<MarioState, StateTransitions>;
  transition: (state: MarioState, event: MarioEvent) => MarioState;
}

const marioStateMachine: StateMachine = { 
  initial: 'normal', 
  states: { 
    normal: { 
      on: { 
        GET_MUSHROOM: 'super', 
        GET_FIRE_FLOWER: 'fire', 
        GET_STAR: 'invincible',
        HIT_OBSTACLE: 'normal'
      } 
    }, 
    super: { 
      on: { 
        GET_FIRE_FLOWER: 'fire', 
        HIT_OBSTACLE: 'normal',
        GET_MUSHROOM: 'super',
        GET_STAR: 'invincible'
      } 
    }, 
    fire: { 
      on: { 
        HIT_OBSTACLE: 'normal',
        GET_MUSHROOM: 'fire',
        GET_FIRE_FLOWER: 'fire',
        GET_STAR: 'invincible'
      } 
    }, 
    invincible: { 
      on: { 
        HIT_OBSTACLE: 'normal',
        GET_MUSHROOM: 'invincible',
        GET_FIRE_FLOWER: 'invincible',
        GET_STAR: 'invincible'
      } 
    } 
  }, 
  transition: function(state: MarioState, event: MarioEvent): MarioState { 
    return this.states[state]?.on[event] || state; 
  } 
};
```

---

## Naming, Testing & Utils

### Naming Conventions
*   **Variable Naming:** Use clear, descriptive names. Include units.
    ```typescript
    const MILLISECONDS_PER_DAY: number = 60 * 60 * 24 * 1000;
    ```
*   **Avoid abbreviations:** `movie.genre` instead of `m.gen`.
*   **File Naming:** Prefer descriptive module names over generic ones like `utils.ts`.

### Testing Strategies
1.  **Unit Tests:** For critical, pure functions.
2.  **Integration Tests:** For systems like queues or batch processes.
3.  **End-to-End (E2E):** For user interactions.
*   **Approach:** Use TDD for libraries and behavior-driven testing for interactive applications.

### Common Array Methods
*   **map()**: Transform elements.
*   **filter()**: Select elements.
*   **reduce()**: Accumulate values.
*   **find()**: Return first match.
*   **some() / every()**: Boolean checks.
