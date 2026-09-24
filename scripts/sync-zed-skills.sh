#!/usr/bin/env bash
#
# Copy Octapowers skills into Zed's native skill directory and prevent Codex
# from loading those copies in addition to the installed Octapowers plugin.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR="$REPO_ROOT/skills"
ZED_SKILLS_DIR="${OCTAPOWERS_ZED_SKILLS_DIR:-$HOME/.agents/skills}"
CODEX_CONFIG="${OCTAPOWERS_CODEX_CONFIG:-$HOME/.codex/config.toml}"
ZED_AGENTS="${OCTAPOWERS_ZED_AGENTS:-$HOME/.config/zed/AGENTS.md}"
SETUP_ZED_ROUTER="${OCTAPOWERS_SETUP_ZED_ROUTER:-1}"
MANIFEST="$ZED_SKILLS_DIR/.octapowers-managed"
BLOCK_START="# octapowers-zed-skills:start"
BLOCK_END="# octapowers-zed-skills:end"
ROUTER_INSTRUCTION='For software-development work, invoke the `using-octapowers` skill before acting.'

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

toml_escape() {
  local value="$1"

  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '%s' "$value"
}

[[ -d "$SOURCE_DIR" ]] || die "skill source directory not found: $SOURCE_DIR"
[[ -n "$ZED_SKILLS_DIR" && "$ZED_SKILLS_DIR" != "/" ]] ||
  die "refusing unsafe Zed skills directory: $ZED_SKILLS_DIR"

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/octapowers-zed-sync.XXXXXX")"
CURRENT_MANIFEST="$WORK_DIR/current"
STAGE="$WORK_DIR/stage"
FILTERED_CONFIG="$WORK_DIR/config"
FILTERED_ZED_AGENTS="$WORK_DIR/zed-agents"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

mkdir -p "$STAGE"

for skill_path in "$SOURCE_DIR"/*; do
  [[ -d "$skill_path" && -f "$skill_path/SKILL.md" ]] || continue
  skill_name="$(basename "$skill_path")"
  is_skill_name "$skill_name" || die "invalid skill directory name: $skill_name"
  printf '%s\n' "$skill_name" >>"$CURRENT_MANIFEST"
  mkdir -p "$STAGE/$skill_name"
  cp -R "$skill_path/." "$STAGE/$skill_name/"
done

[[ -s "$CURRENT_MANIFEST" ]] || die "no skills found in $SOURCE_DIR"
sort -o "$CURRENT_MANIFEST" "$CURRENT_MANIFEST"
mkdir -p "$ZED_SKILLS_DIR"

while IFS= read -r skill_name; do
  [[ -n "$skill_name" ]] || continue
  is_skill_name "$skill_name" || die "invalid skill name in $MANIFEST: $skill_name"
  if [[ -e "$ZED_SKILLS_DIR/$skill_name" ]] &&
    ! contains_line "$skill_name" "$MANIFEST"; then
    die "refusing to overwrite unmanaged Zed skill: $ZED_SKILLS_DIR/$skill_name"
  fi
done <"$CURRENT_MANIFEST"

if [[ -f "$MANIFEST" ]]; then
  while IFS= read -r skill_name; do
    [[ -n "$skill_name" ]] || continue
    is_skill_name "$skill_name" || die "invalid skill name in $MANIFEST: $skill_name"
    if ! contains_line "$skill_name" "$CURRENT_MANIFEST"; then
      rm -rf "${ZED_SKILLS_DIR:?}/$skill_name"
    fi
  done <"$MANIFEST"
fi

while IFS= read -r skill_name; do
  if contains_line "$skill_name" "$MANIFEST"; then
    rm -rf "${ZED_SKILLS_DIR:?}/$skill_name"
  fi
  cp -R "$STAGE/$skill_name" "$ZED_SKILLS_DIR/$skill_name"
done <"$CURRENT_MANIFEST"
cp "$CURRENT_MANIFEST" "$MANIFEST"

mkdir -p "$(dirname "$CODEX_CONFIG")"
touch "$CODEX_CONFIG"
start_count="$(grep -Fxc "$BLOCK_START" "$CODEX_CONFIG" || true)"
end_count="$(grep -Fxc "$BLOCK_END" "$CODEX_CONFIG" || true)"
[[ "$start_count" -le 1 && "$start_count" == "$end_count" ]] ||
  die "malformed Octapowers block in $CODEX_CONFIG"

awk -v start="$BLOCK_START" -v end="$BLOCK_END" '
  $0 == start { skipping = 1; next }
  $0 == end { skipping = 0; next }
  !skipping { print }
' "$CODEX_CONFIG" >"$FILTERED_CONFIG"
cp "$FILTERED_CONFIG" "$CODEX_CONFIG"

{
  printf '\n%s\n' "$BLOCK_START"
  printf '# These copies belong to Zed; Codex uses the installed Octapowers plugin.\n'
  while IFS= read -r skill_name; do
    skill_file="$(toml_escape "$ZED_SKILLS_DIR/$skill_name/SKILL.md")"
    printf '\n[[skills.config]]\n'
    printf 'path = "%s"\n' "$skill_file"
    printf 'enabled = false\n'
  done <"$CURRENT_MANIFEST"
  printf '%s\n' "$BLOCK_END"
} >>"$CODEX_CONFIG"

if [[ "$SETUP_ZED_ROUTER" == "1" ]]; then
  mkdir -p "$(dirname "$ZED_AGENTS")"
  touch "$ZED_AGENTS"
  ZED_BLOCK_START='<!-- octapowers-zed:start -->'
  ZED_BLOCK_END='<!-- octapowers-zed:end -->'
  start_count="$(grep -Fxc "$ZED_BLOCK_START" "$ZED_AGENTS" || true)"
  end_count="$(grep -Fxc "$ZED_BLOCK_END" "$ZED_AGENTS" || true)"
  [[ "$start_count" -le 1 && "$start_count" == "$end_count" ]] ||
    die "malformed Octapowers block in $ZED_AGENTS"
  awk -v start="$ZED_BLOCK_START" -v end="$ZED_BLOCK_END" '
    $0 == start { skipping = 1; next }
    $0 == end { skipping = 0; next }
    !skipping { print }
  ' "$ZED_AGENTS" >"$FILTERED_ZED_AGENTS"
  cp "$FILTERED_ZED_AGENTS" "$ZED_AGENTS"
  {
    printf '\n%s\n' "$ZED_BLOCK_START"
    printf '%s\n' "$ROUTER_INSTRUCTION"
    printf '%s\n' "$ZED_BLOCK_END"
  } >>"$ZED_AGENTS"
fi

skill_count="$(wc -l <"$CURRENT_MANIFEST" | tr -d ' ')"
echo "Copied $skill_count Octapowers skills to $ZED_SKILLS_DIR"
echo "Updated Codex exclusions in $CODEX_CONFIG"
if [[ "$SETUP_ZED_ROUTER" == "1" ]]; then
  echo "Confirmed the Zed router instruction in $ZED_AGENTS"
fi
