#!/usr/bin/env bash
# Copy Octapowers into Antigravity's global Agent Skills directory and keep
# the always-active router instruction in Antigravity's global rules.

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
source_dir="${OCTAPOWERS_SKILLS_SOURCE:-$repo_root/skills}"
skills_dir="${OCTAPOWERS_ANTIGRAVITY_SKILLS_DIR:-$HOME/.gemini/config/skills}"
global_rules="${OCTAPOWERS_ANTIGRAVITY_RULES:-$HOME/.gemini/GEMINI.md}"
manifest="$skills_dir/.octapowers-managed"
block_start="<!-- octapowers-antigravity:start -->"
block_end="<!-- octapowers-antigravity:end -->"
router_instruction='For software-development work, invoke the `using-octapowers` skill before acting.'

die() {
  echo "error: $*" >&2
  exit 1
}

is_skill_name() {
  [[ "$1" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

contains_line() {
  local needle="$1"
  local file="$2"

  [[ -f "$file" ]] && grep -Fxq "$needle" "$file"
}

[[ -d "$source_dir" ]] || die "skill source directory not found: $source_dir"
[[ -n "$skills_dir" && "$skills_dir" != "/" ]] ||
  die "refusing unsafe Antigravity skills directory: $skills_dir"
[[ -n "$global_rules" && "$global_rules" != "/" ]] ||
  die "refusing unsafe Antigravity rules path: $global_rules"

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/octapowers-antigravity-sync.XXXXXX")"
current_manifest="$work_dir/current"
stage="$work_dir/stage"
filtered_rules="$work_dir/rules"

cleanup() {
  rm -rf "$work_dir"
}
trap cleanup EXIT

mkdir -p "$stage"
for skill_path in "$source_dir"/*; do
  [[ -d "$skill_path" && -f "$skill_path/SKILL.md" ]] || continue
  skill_name="$(basename "$skill_path")"
  is_skill_name "$skill_name" || die "invalid skill directory name: $skill_name"
  printf '%s\n' "$skill_name" >>"$current_manifest"
  mkdir -p "$stage/$skill_name"
  cp -R "$skill_path/." "$stage/$skill_name/"
done

[[ -s "$current_manifest" ]] || die "no skills found in $source_dir"
sort -o "$current_manifest" "$current_manifest"
mkdir -p "$skills_dir"

while IFS= read -r skill_name; do
  [[ -n "$skill_name" ]] || continue
  is_skill_name "$skill_name" || die "invalid skill name in $manifest: $skill_name"
  if [[ -e "$skills_dir/$skill_name" ]] &&
    ! contains_line "$skill_name" "$manifest"; then
    die "refusing to overwrite unmanaged Antigravity skill: $skills_dir/$skill_name"
  fi
done <"$current_manifest"

if [[ -f "$manifest" ]]; then
  while IFS= read -r skill_name; do
    [[ -n "$skill_name" ]] || continue
    is_skill_name "$skill_name" || die "invalid skill name in $manifest: $skill_name"
    if ! contains_line "$skill_name" "$current_manifest"; then
      rm -rf "${skills_dir:?}/$skill_name"
    fi
  done <"$manifest"
fi

while IFS= read -r skill_name; do
  if contains_line "$skill_name" "$manifest"; then
    rm -rf "${skills_dir:?}/$skill_name"
  fi
  cp -R "$stage/$skill_name" "$skills_dir/$skill_name"
done <"$current_manifest"
cp "$current_manifest" "$manifest"

mkdir -p "$(dirname "$global_rules")"
touch "$global_rules"
start_count="$(grep -Fxc "$block_start" "$global_rules" || true)"
end_count="$(grep -Fxc "$block_end" "$global_rules" || true)"
[[ "$start_count" -le 1 && "$start_count" == "$end_count" ]] ||
  die "malformed Octapowers block in $global_rules"

awk -v start="$block_start" -v end="$block_end" '
  $0 == start { skipping = 1; next }
  $0 == end { skipping = 0; next }
  !skipping { print }
' "$global_rules" >"$filtered_rules"
cp "$filtered_rules" "$global_rules"

{
  printf '\n%s\n' "$block_start"
  printf '%s\n' "$router_instruction"
  printf '%s\n' "$block_end"
} >>"$global_rules"

skill_count="$(wc -l <"$current_manifest" | tr -d ' ')"
echo "Copied $skill_count Octapowers skills to $skills_dir"
echo "Confirmed the Antigravity router instruction in $global_rules"
