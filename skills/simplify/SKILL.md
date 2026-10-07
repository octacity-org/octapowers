---
name: simplify
description: Use when asked to simplify, refactor, or clean up existing code, or when substantial restructuring is necessary for an authorized change. Improve clarity and maintainability while preserving required behavior. Do not trigger for routine formatting or use as permission for unrelated cleanup.
---

# Simplify

Make existing code easier to understand and maintain. Remove unnecessary
complexity, reuse suitable existing functionality, and choose more direct
implementations. Fewer lines alone do not establish an improvement.

## Understand Before Changing

Identify the concrete difficulty being reduced and the scope of the task.

Inspect the affected code, callers, existing helpers, project patterns, and
tests. Understand contracts, side effects, ordering, error handling, and
resource ownership before replacing apparently redundant code.

Check whether the project already has a simpler way to perform the same job.
Reuse it when its behavior and dependencies fit; similar names are not proof
of equivalent behavior.

## Establish a Baseline

Run relevant existing checks before editing. Distinguish pre-existing failures
from failures introduced by the change.

Use existing coverage where sufficient. Add focused characterization tests
only for important unprotected behavior. These tests describe current behavior
and should pass before restructuring begins.

Pure refactoring follows green → change structure → green. Do not invent a
failing test when no behavior is being added. Use test-driven development for
intentional behavior changes.

## Find a Simpler Implementation

Look for concrete opportunities:

- replace duplicate functionality with a suitable existing helper or API;
- remove unnecessary intermediate state, conversions, or repeated work;
- consolidate accumulated branches and workarounds into coherent logic;
- remove indirection, configuration, or abstractions without a current purpose;
- use a clearer standard operation or algorithm;
- reorganize responsibilities when this makes the affected code easier to follow.

Compare alternatives by the concepts, dependencies, and control flow a reader
must understand. Prefer explicit code over clever compression.

Do not merge code merely because it looks similar. Preserve intentional
differences. Introduce a helper or abstraction only when it reduces meaningful
duplication or clarifies a responsibility.

## Change in Small Steps

Make one coherent transformation at a time and keep relevant checks passing.

Preserve required behavior, including public contracts, errors, side effects,
ordering, and resource lifetimes. Update affected callers together when changing
an internal interface.

Keep intentional behavior changes distinct from structural changes so their
effects can be verified separately.

Do not broaden a local cleanup into an architectural rewrite. Remove code only
when evidence establishes that it is unnecessary within the authorized scope.
Do not discard pre-existing user work.

## Verify and Stop

Check both correctness and the stated simplification goal. Passing tests alone
do not prove the code became clearer.

Review the result for fewer unnecessary concepts, clearer control flow, suitable
reuse, and reduced maintenance burden. Refactor affected tests when needed
without weakening their behavioral coverage.

Stop when the concrete difficulty is resolved. Do not continue searching for
unrelated cleanup opportunities.

Use performance-investigation when the task requires a measured performance
improvement. Do not claim speed or memory gains from inspection alone.

Briefly report what became simpler, what behavior was preserved, and which
checks passed. State any remaining uncertainty.
