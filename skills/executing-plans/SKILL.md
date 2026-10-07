---
name: executing-plans
description: Execute an approved written implementation plan when the user asks to proceed with it. Use the current session and a proportional workflow unless the user explicitly requests subagent-driven development or a worktree.
---

# Executing Plans

## Overview

Load the approved plan, review it critically, execute it proportionally, verify the result, and report completion.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If a critical ambiguity would materially change the outcome: raise it before starting
4. If no concerns: Create todos for the plan items and proceed

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. Follow the plan's intent and constraints; adapt incidental implementation details when reality requires it
3. Run verifications as specified
4. Mark as completed

### Step 3: Complete Development

After all tasks complete, run verification appropriate to the change and report the result. Use `finishing-a-development-branch` only when the user asks to merge, open a PR, clean up, or otherwise finish the branch workflow.

## Resolve Failures and Blockers

Investigate ordinary test failures and setup problems within the approved scope. Use `systematic-debugging` when needed, distinguish expected TDD failures from regressions, and continue independent tasks when safe.

Ask only when progress requires a missing user decision, permission, unavailable external resource, or material change to the plan's goal or constraints. Report the evidence, attempted resolution, and exact decision needed. Repeated failures call for reassessing the hypothesis, not automatically handing the problem back to the user.

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

Preserve the plan's intent and constraints; resolve incidental implementation details from repository evidence.

## Remember
- Review plan critically first
- Follow the plan's intent and constraints
- Don't skip verifications
- Reference skills when plan says to
- Resolve routine failures; escalate consequential blockers with evidence
- Respect repository instructions and the user's requested branch workflow

## Integration

**Related skills:**
- `writing-plans` creates the approved plan this skill executes.
- Use `subagent-driven-development` only when the user explicitly requests it.
- Use `using-git-worktrees` only when the user explicitly requests a worktree.
- Use `finishing-a-development-branch` when the user asks to finish the branch workflow.
