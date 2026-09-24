#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
skill="$root/skills/language-style"
languages=(rust go python typescript javascript swift zig c cpp)

for language in "${languages[@]}"; do
  reference="$skill/references/$language.md"
  test -f "$reference"
  lines="$(wc -l < "$reference" | tr -d ' ')"
  if (( lines > 100 )); then
    echo "$language.md exceeds the 100-line cap: $lines" >&2
    exit 1
  fi
  rg -q '^## Format' "$reference"
  rg -q '^## Performance' "$reference"
  rg -q '^## Verification' "$reference"
  rg -q '^## Sources' "$reference"
  rg -q "references/$language.md" "$skill/SKILL.md"
done

rg -q 'use `language-style`' "$root/skills/using-octapowers/SKILL.md"
if rg -n 'TODO|\[TODO' "$skill"; then
  echo "language-style contains unfinished template text" >&2
  exit 1
fi

echo "language-style policy checks passed"
