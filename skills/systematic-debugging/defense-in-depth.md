# Defense-in-Depth Validation

## Overview

When invalid data causes a bug, trace its origin and the operation that needs protection. Fix the cause and validate at the authoritative boundary. Add further checks only when evidence shows that the boundary can legitimately be bypassed or a different invariant needs protection.

**Core principle:** Each additional check needs a distinct invariant, trust boundary, or independently reachable path.

## Choose Necessary Controls

Identify the contract at each relevant boundary. Avoid repeating the same validation along a path whose upstream contract already guarantees it. A mock bypassing a real contract is usually a test-fixture problem, not evidence that production needs another check.

Possible controls serve different purposes; they are not four mandatory layers:

- Entry validation establishes the accepted input contract.
- Business validation enforces operation-specific invariants.
- Environment guards protect a genuine execution boundary.
- Debug logging provides evidence; it does not prevent invalid operations.

## Examples of Controls

### Layer 1: Entry Point Validation
**Purpose:** Reject obviously invalid input at API boundary

```typescript
function createProject(name: string, workingDirectory: string) {
  if (!workingDirectory || workingDirectory.trim() === '') {
    throw new Error('workingDirectory cannot be empty');
  }
  if (!existsSync(workingDirectory)) {
    throw new Error(`workingDirectory does not exist: ${workingDirectory}`);
  }
  if (!statSync(workingDirectory).isDirectory()) {
    throw new Error(`workingDirectory is not a directory: ${workingDirectory}`);
  }
  // ... proceed
}
```

### Layer 2: Business Logic Validation
**Purpose:** Ensure data makes sense for this operation

```typescript
function initializeWorkspace(projectDir: string, sessionId: string) {
  if (!projectDir) {
    throw new Error('projectDir required for workspace initialization');
  }
  // ... proceed
}
```

### Layer 3: Environment Guards
**Purpose:** Prevent dangerous operations in specific contexts

```typescript
async function gitInit(directory: string) {
  // In tests, refuse git init outside temp directories
  if (process.env.NODE_ENV === 'test') {
    const relativePath = relative(resolve(tmpdir()), resolve(directory));

    if (isAbsolute(relativePath) || relativePath === '..' || relativePath.startsWith(`..${sep}`)) {
      throw new Error(
        `Refusing git init outside temp dir during tests: ${directory}`
      );
    }
  }
  // ... proceed
}
```

This lexical check uses Node's `relative`, `resolve`, `isAbsolute`, and `sep` from `node:path`. It does not establish containment through symlinks. Prefer controlling test directories in the harness rather than introducing test-only production branches; a real filesystem security boundary needs stronger containment checks.

### Layer 4: Debug Instrumentation
**Purpose:** Capture context for forensics

```typescript
async function gitInit(directory: string) {
  const stack = new Error().stack;
  logger.debug('About to git init', {
    directory,
    cwd: process.cwd(),
    stack,
  });
  // ... proceed
}
```

## Applying the Pattern

When you find a bug:

1. **Trace the data flow** - Where does bad value originate? Where used?
2. **Identify boundaries** - Find the authoritative control and independently reachable paths
3. **Justify each check** - Name the distinct invariant or bypass it addresses
4. **Verify meaningful failures** - Reuse existing coverage; add cases only for unprotected paths or invariants

## Example

Bug: Empty `projectDir` caused `git init` in source code

**Data flow:**
1. Test setup → empty string
2. `Project.create(name, '')`
3. `WorkspaceManager.createWorkspace('')`
4. `git init` runs in `process.cwd()`

Reject an empty directory at the authoritative entry point and fix the test setup. Add validation in `WorkspaceManager` only if it is independently callable without that entry contract. Keep test directory restrictions in the harness when possible. Use temporary logging only if needed to locate the source, then remove it.

## Key Insight

Several controls can be necessary, but each must protect a concrete property. More checks and more tests do not establish correctness by themselves. Preserve useful independent controls and remove redundant checks only after verifying their callers and contracts.
