#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
show_me="$repo_root/skills/show-me/SKILL.md"
router="$repo_root/skills/using-octapowers/SKILL.md"
brainstorming="$repo_root/skills/brainstorming/SKILL.md"
companion="$repo_root/skills/brainstorming/visual-companion.md"
readme="$repo_root/README.md"

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

if [[ ! -f "$show_me" ]]; then
  echo "FAIL: missing $show_me" >&2
  exit 1
fi

assert_contains "$show_me" "name: show-me"
assert_contains "$show_me" "Use only when the user explicitly asks"
assert_contains "$show_me" "Pick the smallest visual form"
assert_contains "$show_me" "Base repository diagrams on inspected code."
assert_contains "$show_me" "verified, inferred, conceptual, simplified, or proposed"
assert_contains "$show_me" "Algorithm or compact logic"
assert_contains "$show_me" "Nested calls"
assert_contains "$show_me" "UI ownership"
assert_contains "$show_me" "Repository responsibility"
assert_contains "$show_me" "Interactions over time"
assert_contains "$show_me" "Branching, state, or data flow"
assert_contains "$show_me" "Change to an existing shape"
assert_contains "$show_me" "Prefer one primary visual."
assert_contains "$show_me" "Keep a brief textual conclusion beside every visual."
assert_contains "$show_me" "only when text diagrams or Mermaid cannot communicate"
assert_contains "$show_me" "Prefer the host's native visualization mechanism"
assert_contains "$show_me" "valid workspace or user-specified location"
assert_contains "$show_me" "report its path"
assert_contains "$show_me" "avoid leaving unnecessary artifacts behind"
assert_contains "$show_me" "accessible title and description"
assert_contains "$show_me" "Validate Mermaid syntax"
assert_contains "$show_me" "[interactive visual companion](../brainstorming/visual-companion.md)"
assert_not_contains "$show_me" "Bash(open"

assert_contains "$router" 'Visualization explicitly requested: use `show-me`.'
assert_contains "$brainstorming" 'invoke `show-me`'
assert_not_contains "$brainstorming" "[visual-companion.md](visual-companion.md)"
assert_contains "$companion" 'Read this guide only after `show-me` selects an interactive browser artifact.'
assert_contains "$readme" '`show-me`: explicit, focused visual explanations'

line_count="$(wc -l < "$show_me" | tr -d ' ')"
if (( line_count > 200 )); then
  echo "FAIL: expected at most 200 lines in $show_me, found $line_count" >&2
  exit 1
fi

echo "PASS: show-me policy"
