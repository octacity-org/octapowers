#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/sync-zed-skills.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/octapowers-zed-sync.XXXXXX")"
SKILLS_DIR="$TEST_ROOT/.agents/skills"
CODEX_CONFIG="$TEST_ROOT/.codex/config.toml"
ZED_AGENTS="$TEST_ROOT/.config/zed/AGENTS.md"

cleanup() {
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

mkdir -p "$SKILLS_DIR/unrelated-skill" "$SKILLS_DIR/using-superpowers" "$(dirname "$CODEX_CONFIG")" "$(dirname "$ZED_AGENTS")"
printf '%s\n' "keep me" >"$SKILLS_DIR/unrelated-skill/SKILL.md"
printf '%s\n' "old router" >"$SKILLS_DIR/using-superpowers/SKILL.md"
printf '%s\n' "using-superpowers" >"$SKILLS_DIR/.octapowers-managed"
printf '%s\n' 'model = "test-model"' >"$CODEX_CONFIG"
printf '%s\n' "Keep this Zed instruction." '<!-- octapowers-zed:start -->' \
  'For software-development work, invoke the `using-superpowers` skill before acting.' \
  '<!-- octapowers-zed:end -->' >"$ZED_AGENTS"

OCTAPOWERS_ZED_SKILLS_DIR="$SKILLS_DIR" \
  OCTAPOWERS_CODEX_CONFIG="$CODEX_CONFIG" \
  OCTAPOWERS_ZED_AGENTS="$ZED_AGENTS" \
  "$SCRIPT_UNDER_TEST"

[[ -f "$SKILLS_DIR/brainstorming/SKILL.md" ]] ||
  fail "copies Octapowers skills"
[[ ! -L "$SKILLS_DIR/brainstorming" ]] ||
  fail "installs copies rather than symlinks"
cmp -s "$REPO_ROOT/skills/brainstorming/SKILL.md" "$SKILLS_DIR/brainstorming/SKILL.md" ||
  fail "copied skill matches the repository"
[[ -f "$SKILLS_DIR/unrelated-skill/SKILL.md" ]] ||
  fail "preserves unrelated skills"
[[ ! -e "$SKILLS_DIR/using-superpowers" ]] ||
  fail "removes the previously managed router name"
grep -Fq 'model = "test-model"' "$CODEX_CONFIG" ||
  fail "preserves existing Codex configuration"
grep -Fq "Keep this Zed instruction." "$ZED_AGENTS" ||
  fail "preserves existing Zed instructions"
grep -Fq 'invoke the `using-octapowers` skill before acting' "$ZED_AGENTS" ||
  fail "adds the Zed router instruction"
! grep -Fq 'invoke the `using-superpowers` skill before acting' "$ZED_AGENTS" ||
  fail "replaces the old Zed router instruction"

expected_skill_count="$(
  find "$REPO_ROOT/skills" -mindepth 1 -maxdepth 1 -type d -exec test -f '{}/SKILL.md' ';' -print |
    wc -l | tr -d ' '
)"
disabled_skill_count="$(grep -c '^enabled = false$' "$CODEX_CONFIG")"
[[ "$disabled_skill_count" == "$expected_skill_count" ]] ||
  fail "writes one Codex exclusion per Octapowers skill"
grep -Fq "path = \"$SKILLS_DIR/using-octapowers/SKILL.md\"" "$CODEX_CONFIG" ||
  fail "disables the copied router in Codex"

printf '%s\n' "stale" >"$SKILLS_DIR/brainstorming/stale-file"
mkdir -p "$SKILLS_DIR/removed-octapower"
printf '%s\n' "removed-octapower" >>"$SKILLS_DIR/.octapowers-managed"

OCTAPOWERS_ZED_SKILLS_DIR="$SKILLS_DIR" \
  OCTAPOWERS_CODEX_CONFIG="$CODEX_CONFIG" \
  OCTAPOWERS_ZED_AGENTS="$ZED_AGENTS" \
  "$SCRIPT_UNDER_TEST"

[[ ! -e "$SKILLS_DIR/brainstorming/stale-file" ]] ||
  fail "replaces managed skill copies exactly"
[[ ! -e "$SKILLS_DIR/removed-octapower" ]] ||
  fail "removes skills formerly managed by Octapowers"
[[ "$(grep -c '^# octapowers-zed-skills:start$' "$CODEX_CONFIG")" == "1" ]] ||
  fail "keeps one managed Codex configuration block"
[[ "$(grep -c 'invoke the `using-octapowers` skill before acting' "$ZED_AGENTS")" == "1" ]] ||
  fail "keeps one Zed router instruction"

echo "PASS: Zed skill synchronization"
