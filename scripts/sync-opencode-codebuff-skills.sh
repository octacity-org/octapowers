#!/usr/bin/env bash
# Share Octapowers skills with OpenCode and Codebuff without duplicating them in Codex.

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
opencode_rules="${OCTAPOWERS_OPENCODE_AGENTS:-$HOME/.config/opencode/AGENTS.md}"
codebuff_rules="${OCTAPOWERS_CODEBUFF_RULES:-}"

if [[ -z "$codebuff_rules" ]]; then
  for candidate in "$HOME/.knowledge.md" "$HOME/.AGENTS.md" "$HOME/.CLAUDE.md"; do
    if [[ -f "$candidate" ]]; then
      codebuff_rules="$candidate"
      break
    fi
  done
  codebuff_rules="${codebuff_rules:-$HOME/.knowledge.md}"
fi

router='For software-development work, invoke the `using-octapowers` skill before acting.'

check_rules_file() {
  local file="$1"
  local start="$2"
  local end="$3"
  local start_count end_count

  [[ -n "$file" && "$file" != "/" ]] || {
    echo "error: unsafe rules path: $file" >&2
    exit 1
  }
  [[ ! -L "$file" ]] || {
    echo "error: refusing to modify symlinked rules file: $file" >&2
    exit 1
  }
  [[ -f "$file" || ! -e "$file" ]] || {
    echo "error: rules path is not a file: $file" >&2
    exit 1
  }
  start_count="$(grep -Fxc "$start" "$file" 2>/dev/null || true)"
  end_count="$(grep -Fxc "$end" "$file" 2>/dev/null || true)"
  [[ "$start_count" -le 1 && "$start_count" == "$end_count" ]] || {
    echo "error: malformed Octapowers block in $file" >&2
    exit 1
  }
}

update_rules_file() {
  local file="$1"
  local start="$2"
  local end="$3"
  local temporary

  mkdir -p "$(dirname "$file")"
  touch "$file"
  temporary="$(mktemp "${TMPDIR:-/tmp}/octapowers-rules.XXXXXX")"
  awk -v start="$start" -v end="$end" '
    $0 == start { skipping = 1; next }
    $0 == end { skipping = 0; next }
    !skipping { print }
  ' "$file" >"$temporary"
  {
    printf '\n%s\n' "$start"
    printf '%s\n' "$router"
    printf '%s\n' "$end"
  } >>"$temporary"
  cp "$temporary" "$file"
  rm "$temporary"
}

opencode_start='<!-- octapowers-opencode:start -->'
opencode_end='<!-- octapowers-opencode:end -->'
codebuff_start='<!-- octapowers-codebuff:start -->'
codebuff_end='<!-- octapowers-codebuff:end -->'

check_rules_file "$opencode_rules" "$opencode_start" "$opencode_end"
check_rules_file "$codebuff_rules" "$codebuff_start" "$codebuff_end"

OCTAPOWERS_SETUP_ZED_ROUTER=0 "$script_dir/sync-zed-skills.sh"
update_rules_file "$opencode_rules" "$opencode_start" "$opencode_end"
update_rules_file "$codebuff_rules" "$codebuff_start" "$codebuff_end"

echo "Confirmed the OpenCode router instruction in $opencode_rules"
echo "Confirmed the Codebuff router instruction in $codebuff_rules"
