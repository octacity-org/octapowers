---
name: test-driven-development
description: Use by default before implementation for every non-tiny feature, bug fix, or behavior change. Require a failing automated check before production behavior changes and strict red-green-refactor. Pure refactors use a verified green baseline under simplify. Skip for trivial mechanical edits or when the user explicitly says not to write tests, not to use TDD, or gives an equivalent instruction.
---

# Test-Driven Development

Write the test first, observe the expected failure, then write the minimum production code needed to pass it.

## Entry Condition

TDD is the default for every non-tiny implementation change. Do not use for trivial mechanical edits such as typos, comments, formatting, or an obvious line or two without meaningful behavior risk.

Practicality changes the form of the failing check, not the default. Choose the smallest useful unit, integration, contract, compile, snapshot, or validation check. Test generated output through its generator or contract and configuration through its observable outcome.

An explicit user instruction to skip tests or TDD overrides the default. Do not infer this override from urgency, speed, or silence.

“Do not write tests” does not also mean “do not run tests.” Run existing verification unless separately prohibited; then report the limitation.

Once selected, the red-green-refactor order is mandatory. Do not silently substitute tests-after because the change appears easy.

## Core Rule

Do not write production behavior for an increment until a test demonstrates that the behavior is missing or incorrect.

If production code was written first, revert production code written during this task for that increment and restart from the failing test without retaining a template. Never delete or overwrite pre-existing user code.

## Choose the Next Test

Inspect existing coverage. List required behaviors and meaningful failures; implement one test at a time. For each addition, identify a failure existing tests would miss. Extend existing tests or parameterize cases when clear.

Test stable interfaces, not every helper or implementation step. Test internals when complexity or diagnosis justifies it. Add another layer only for a distinct risk, such as persistence or wiring.

Use representative inputs and meaningful boundaries, not equivalent cases, speculative requirements, or unreachable states.

## Red → Green → Refactor

### RED

Write one focused test that describes externally meaningful behavior:

- give it a clear behavioral name;
- exercise real code and mock only genuine boundaries;
- keep failure attributable to one missing or incorrect behavior.

Use the project's configured test command. Confirm the focused test fails meaningfully. An expected compile failure can be a valid red state.

If it passes immediately, correct the test or confirm the behavior exists. Fix setup errors before proceeding.

### GREEN

Implement the simplest change that passes. Avoid speculative behavior, abstractions, and unrelated refactoring.

Rerun the test. Fix production code; do not weaken correct expectations to obtain green.

### REFACTOR

After green, improve structure without adding behavior. For pure refactors, establish a verified green baseline and work in small green steps using existing coverage.

Refactor tests too: consolidate repetition and review new tests for duplicate assertions, implementation coupling, and unnecessary mocks. Preserve clarity and coverage; never remove pre-existing coverage merely to reduce volume.

Repeat the cycle for the next behavior increment.

## Bugs and Completion

For a reproducible bug, write the smallest regression test that fails because of the bug before applying the fix.

Before completion, confirm:

- every behavior increment was observed red for the expected reason;
- minimal implementation made it green;
- relevant regression checks pass after refactoring;
- edge cases and error behavior required by the task are covered.

Stop when requested behaviors, relevant failures, and known regressions are covered and required checks pass. Additional tests need an uncovered requirement or risk, not a test-count, coverage, or code-ratio target.

If a selected increment cannot be tested meaningfully, stop and explain the constraint rather than pretending tests-after followed TDD.

Read [testing-anti-patterns.md](testing-anti-patterns.md) when introducing mocks, test utilities, or test-only production hooks.
