#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"
script_under_test="$repo_root/scripts/sync-antigravity-skills.sh"
router="$repo_root/skills/using-octapowers/SKILL.md"
platform_reference="$repo_root/skills/using-octapowers/references/antigravity.md"
readme="$repo_root/README.md"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/octapowers-antigravity-sync.XXXXXX")"
skills_dir="$test_root/.gemini/config/skills"
global_rules="$test_root/.gemini/GEMINI.md"

cleanup() {
  rm -rf "$test_root"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

grep -Fq -- '- Antigravity IDE' "$readme" ||
  fail "README declares Antigravity support"
grep -Fq 'scripts/sync-antigravity-skills.sh' "$readme" ||
  fail "README documents Antigravity installation"
grep -Fq 'references/antigravity.md' "$router" ||
  fail "router links Antigravity platform guidance"
grep -Fq '.gemini/config/skills' "$platform_reference" ||
  fail "platform guidance names the global skill path"
grep -Fq '.gemini/GEMINI.md' "$platform_reference" ||
  fail "platform guidance names the global rules path"

mkdir -p "$skills_dir/unrelated-skill" "$(dirname "$global_rules")"
printf '%s\n' "keep me" >"$skills_dir/unrelated-skill/SKILL.md"
printf '%s\n' "Keep this Antigravity instruction." >"$global_rules"

OCTAPOWERS_ANTIGRAVITY_SKILLS_DIR="$skills_dir" \
  OCTAPOWERS_ANTIGRAVITY_RULES="$global_rules" \
  "$script_under_test"

[[ -f "$skills_dir/using-octapowers/SKILL.md" ]] ||
  fail "copies the Octapowers router"
[[ -f "$skills_dir/show-me/SKILL.md" ]] ||
  fail "copies every current Octapowers skill"
[[ ! -L "$skills_dir/using-octapowers" ]] ||
  fail "installs copies rather than symlinks"
cmp -s "$repo_root/skills/using-octapowers/SKILL.md" \
  "$skills_dir/using-octapowers/SKILL.md" ||
  fail "copied router matches the repository"
[[ -f "$skills_dir/unrelated-skill/SKILL.md" ]] ||
  fail "preserves unrelated global skills"
grep -Fq "Keep this Antigravity instruction." "$global_rules" ||
  fail "preserves existing global rules"
grep -Fq 'invoke the `using-octapowers` skill before acting' "$global_rules" ||
  fail "adds the global router instruction"

expected_skill_count="$({
  find "$repo_root/skills" -mindepth 1 -maxdepth 1 -type d \
    -exec test -f '{}/SKILL.md' ';' -print
} | wc -l | tr -d ' ')"
managed_skill_count="$(wc -l <"$skills_dir/.octapowers-managed" | tr -d ' ')"
[[ "$managed_skill_count" == "$expected_skill_count" ]] ||
  fail "records every managed Octapowers skill"

printf '%s\n' "stale" >"$skills_dir/using-octapowers/stale-file"
mkdir -p "$skills_dir/removed-octapower"
printf '%s\n' "removed-octapower" >>"$skills_dir/.octapowers-managed"

OCTAPOWERS_ANTIGRAVITY_SKILLS_DIR="$skills_dir" \
  OCTAPOWERS_ANTIGRAVITY_RULES="$global_rules" \
  "$script_under_test"

[[ ! -e "$skills_dir/using-octapowers/stale-file" ]] ||
  fail "replaces managed skill copies exactly"
[[ ! -e "$skills_dir/removed-octapower" ]] ||
  fail "removes skills formerly managed by Octapowers"
[[ "$(grep -c '^<!-- octapowers-antigravity:start -->$' "$global_rules")" == "1" ]] ||
  fail "keeps one managed global-rules block"
[[ "$(grep -c 'invoke the `using-octapowers` skill before acting' "$global_rules")" == "1" ]] ||
  fail "keeps one global router instruction"

mkdir -p "$skills_dir/conflicting-skill"
printf '%s\n' "unmanaged" >"$skills_dir/conflicting-skill/SKILL.md"
mkdir -p "$test_root/source/conflicting-skill"
printf '%s\n' $'---\nname: conflicting-skill\ndescription: Test fixture.\n---' \
  >"$test_root/source/conflicting-skill/SKILL.md"
if OCTAPOWERS_ANTIGRAVITY_SKILLS_DIR="$skills_dir" \
  OCTAPOWERS_ANTIGRAVITY_RULES="$global_rules" \
  OCTAPOWERS_SKILLS_SOURCE="$test_root/source" \
  "$script_under_test" >/dev/null 2>&1; then
  fail "rejects an invalid source rather than touching installed skills"
fi

echo "PASS: Antigravity global skill synchronization"
