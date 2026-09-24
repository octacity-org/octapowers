#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
router="$repo_root/skills/using-octapowers/SKILL.md"
brainstorming="$repo_root/skills/brainstorming/SKILL.md"
plans="$repo_root/skills/writing-plans/SKILL.md"
tdd="$repo_root/skills/test-driven-development/SKILL.md"
executing="$repo_root/skills/executing-plans/SKILL.md"
subagents="$repo_root/skills/subagent-driven-development/SKILL.md"
worktrees="$repo_root/skills/using-git-worktrees/SKILL.md"
writing_skills="$repo_root/skills/writing-skills/SKILL.md"
parallel_agents="$repo_root/skills/dispatching-parallel-agents/SKILL.md"
finishing="$repo_root/skills/finishing-a-development-branch/SKILL.md"
receiving_review="$repo_root/skills/receiving-code-review/SKILL.md"
requesting_review="$repo_root/skills/requesting-code-review/SKILL.md"
debugging="$repo_root/skills/systematic-debugging/SKILL.md"
verification="$repo_root/skills/verification-before-completion/SKILL.md"

assert_contains() {
  local file="$1"
  local pattern="$2"
  if ! grep -Fq -- "$pattern" "$file"; then
    echo "FAIL: expected '$pattern' in $file" >&2
    exit 1
  fi
}

assert_not_contains() {
  local file="$1"
  local pattern="$2"
  if grep -Fq -- "$pattern" "$file"; then
    echo "FAIL: unexpected '$pattern' in $file" >&2
    exit 1
  fi
}

assert_word_count_at_most() {
  local file="$1"
  local maximum="$2"
  local count
  count="$(wc -w < "$file" | tr -d ' ')"
  if (( count > maximum )); then
    echo "FAIL: expected at most $maximum words in $file, found $count" >&2
    exit 1
  fi
}

assert_contains "$router" "Treat a moderate workflow as the default"
assert_contains "$router" "Octapowers is always active, but its individual skills are not."
assert_contains "$router" "## Implementation Economy"
assert_contains "$router" "prefer the smallest coherent change that completely satisfies the requested behavior"
assert_contains "$router" "not code golf"
assert_contains "$router" "Extend an existing path before creating a parallel mechanism."
assert_contains "$router" "multiple concrete uses or protects a meaningful boundary, invariant, or resource lifetime"
assert_contains "$router" "Do not add speculative configuration, extension points, compatibility layers, fallbacks, or generalized APIs"
assert_contains "$router" "Do not introduce a dependency when existing project facilities or a small clear implementation are sufficient."
assert_contains "$router" "Keep unrelated cleanup and architectural refactoring outside the requested change unless necessary for correctness."
assert_contains "$router" "Prefer explicit local code when extracting a helper would merely relocate or obscure a one-off operation."
assert_contains "$router" "Remove only scaffolding, dead branches, redundant wrappers, and options introduced during the current task"
assert_contains "$router" "Never modify, revert, or delete pre-existing user work merely to reduce the diff."
assert_contains "$router" "fewer concepts and a smaller maintenance surface"
assert_contains "$router" "Create a written design or implementation plan only when the user explicitly requests that artifact or gated workflow."
assert_contains "$router" 'Invoking `brainstorming` by name without requesting a document selects exploratory brainstorming'
assert_contains "$router" "create any useful internal spec or plan privately and keep moving"
assert_contains "$router" "Subagent-driven development, parallel-agent dispatch, and worktrees: use only when the user explicitly requests them."
assert_contains "$router" "Code review: perform proportional self-review"
assert_contains "$router" "Branch finishing: use only when the user explicitly asks"
assert_contains "$router" 'explicitly asks to remember a project-specific instruction'
assert_contains "$router" 'closest applicable `AGENTS.md`'
assert_contains "$router" 'create `AGENTS.md` at the repository root'
assert_contains "$router" 'state that `AGENTS.md` was updated and summarize what it will remember'
assert_contains "$router" 'Do not persist secrets, temporary task details, guesses'
assert_contains "$brainstorming" "Exploratory brainstorming"
assert_contains "$brainstorming" "Do not create a document or approval gate."
assert_contains "$brainstorming" 'If the request says only “brainstorm,” use exploratory brainstorming.'
assert_contains "$brainstorming" "This approval gate applies only because the user explicitly requested a persistent written design workflow."
assert_contains "$brainstorming" "In either mode"
assert_contains "$plans" "only when the user explicitly requests a written implementation plan"
assert_contains "$plans" 'ensure the project-root `.gitignore` ignores `/docs/octapowers/plans/`'
git -C "$repo_root" check-ignore -q docs/octapowers/plans/example.md || {
  echo "FAIL: repository does not ignore temporary implementation plans" >&2
  exit 1
}
assert_contains "$plans" "If the user explicitly says to plan and then execute automatically, that authorization replaces the approval pause."
assert_contains "$router" 'Use `test-driven-development` by default for every non-tiny implementation or behavior change.'
assert_contains "$router" 'Skip TDD when the user explicitly says not to write tests, not to use TDD, or gives an equivalent instruction.'
assert_contains "$tdd" "TDD is the default for every non-tiny implementation change."
assert_contains "$tdd" "Practicality changes the form of the failing check, not the default."
assert_contains "$tdd" "An explicit user instruction to skip tests or TDD overrides the default."
assert_contains "$tdd" "Do not infer this override from urgency"
assert_contains "$tdd" '“Do not write tests” does not also mean “do not run tests.”'
assert_contains "$tdd" "Do not use for trivial mechanical edits"
assert_contains "$executing" 'Use `subagent-driven-development` only when the user explicitly requests it.'
assert_contains "$executing" 'Use `using-git-worktrees` only when the user explicitly requests a worktree.'
assert_contains "$subagents" "only when the user explicitly requests subagent-driven development"
assert_contains "$subagents" "Do not trigger for generic delegation, parallel-agent requests"
assert_contains "$subagents" "Do not create per-task commits."
assert_contains "$worktrees" "only when the user explicitly requests a worktree"
assert_contains "$worktrees" "Detect existing isolation before creating anything."
assert_contains "$worktrees" "Prefer a platform-native worktree mechanism"
assert_contains "$worktrees" "Verify a project-local worktree directory is ignored"
assert_contains "$worktrees" "Do not commit the ignore change automatically."
assert_contains "$worktrees" "Follow project instructions and existing lockfiles"
assert_contains "$worktrees" "Run the project's focused baseline verification"
assert_contains "$brainstorming" 'invoke `show-me`'
assert_contains "$writing_skills" "Do not require subagent pressure testing for every edit."
assert_contains "$parallel_agents" "only when the user explicitly requests parallel agents or delegation"
assert_contains "$parallel_agents" "Assign non-overlapping ownership"
assert_contains "$finishing" "only when the user explicitly asks to finish a branch workflow"
assert_contains "$finishing" "Ask only when the requested outcome is ambiguous"
assert_contains "$receiving_review" "Clarify only the items whose ambiguity blocks correct implementation"
assert_contains "$requesting_review" "Perform a focused self-review by default"
assert_contains "$requesting_review" "Dispatch an independent reviewer or subagent only when the user explicitly requests one"
assert_contains "$debugging" "Add a regression test when practical"
assert_contains "$debugging" "Repeated failed hypotheses"
assert_contains "$verification" "Do not claim more than current evidence proves."
assert_contains "$verification" "Run the smallest fresh command"
assert_contains "$verification" "Distinguish a focused check from a full suite"
assert_contains "$verification" "Do not rerun unchanged verification"
assert_contains "$verification" "Inspect delegated work"
assert_contains "$tdd" "Once selected, the red-green-refactor order is mandatory."
assert_contains "$tdd" "revert production code written during this task"
assert_contains "$tdd" "Never delete or overwrite pre-existing user code"
assert_contains "$tdd" "An expected compile failure can be a valid red state"
assert_contains "$tdd" "Use the project's configured test command."

assert_not_contains "$router" "1% chance"
assert_not_contains "$brainstorming" "This applies to EVERY project"
assert_not_contains "$plans" "Each step is one action (2-5 minutes)"
assert_not_contains "$executing" "REQUIRED SUB-SKILL"
assert_not_contains "$subagents" "Commit your work"
assert_not_contains "$parallel_agents" "Real-World Impact"
assert_not_contains "$finishing" "present exactly these 4 options"
assert_not_contains "$receiving_review" "ANY gratitude expression"
assert_not_contains "$requesting_review" "After each task in subagent-driven development"
assert_not_contains "$debugging" "You MUST complete each phase"
assert_not_contains "$debugging" "First-time fix rate: 95%"
assert_not_contains "$worktrees" "Announce at start"
assert_not_contains "$worktrees" "npm install"
assert_not_contains "$verification" "dishonesty"
assert_not_contains "$verification" "Skip any step = lying"
assert_not_contains "$tdd" "npm test"
assert_not_contains "$tdd" "Sunk cost fallacy"

assert_word_count_at_most "$verification" 350
assert_word_count_at_most "$tdd" 650
assert_word_count_at_most "$worktrees" 500

if grep -R -E -n --exclude-dir=.git 'docs/superpowers|\.superpowers|Superpowers|SUPERPOWERS' "$repo_root/skills"; then
  echo "FAIL: stale Superpowers reference under skills/" >&2
  exit 1
fi

echo "PASS: proportional workflow policy"
