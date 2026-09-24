---
name: writing-plans
description: Create a persistent implementation plan when the user explicitly requests a written plan or invokes this skill. Do not trigger merely because a task is large, ambitious, or multi-step; use an internal plan and continue in those cases.
---

# Written Implementation Plans

Create an implementation plan that another capable engineer or agent can execute without rediscovering the important decisions.

## Entry Condition

Use this workflow only when the user explicitly requests a written implementation plan or invokes this skill by name.

Large tasks do not automatically require a written plan. If the user simply asks to implement a large task, reason internally, implement, verify, and continue without an approval gate.

## Prerequisite and Approval

If the requested plan depends on unresolved product or architectural decisions, first create or obtain an approved written design. Do not disguise design decisions as implementation steps.

After writing the plan, ask the user to approve or revise it before implementation. If the user explicitly says to plan and then execute automatically, that authorization replaces the approval pause.

## Plan Contents

Include only detail that improves execution:

- goal and relevant constraints;
- chosen approach and important boundaries;
- exact files or modules when known;
- ordered implementation tasks with clear outcomes;
- dependencies between tasks;
- verification for each meaningful unit and for the completed change;
- migrations, rollout, compatibility, or recovery steps when relevant.

Scale the plan to the work. Prefer outcome-sized tasks over artificial 2-5 minute steps. Include code snippets only when an exact interface, schema, or tricky algorithm must be locked down.

Do not require a commit after every task. Do not require subagents, worktrees, or a particular execution method unless the user requests them or the project workflow requires them.

## Output

Save the plan to `docs/octapowers/plans/YYYY-MM-DD-<feature-name>.md`, unless the user specifies another location.

When using this default location in a Git repository, ensure the project-root `.gitignore` ignores `/docs/octapowers/plans/` before saving the plan. Add the rule if needed without disturbing existing entries. This keeps temporary plans out of future commits; if a plan is already tracked, explain that `.gitignore` alone cannot untrack it. Do not remove a tracked plan without the user's request.

Before delivery, check that:

- every requirement is covered;
- task ordering and interfaces are consistent;
- commands, paths, and configuration names are real;
- no placeholders or vague "handle errors" steps remain;
- the plan does not include unrelated refactoring.

Then present the path and request approval or revision. After approval, implement in the current session unless the user asks for another execution arrangement.
