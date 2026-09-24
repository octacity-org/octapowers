#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"
hook="$repo_root/hooks/session-start"
wrapper="$repo_root/hooks/run-hook.cmd"

assert_claude_payload() {
  local output="$1"
  printf '%s' "$output" | node -e '
const fs = require("fs");
const payload = JSON.parse(fs.readFileSync(0, "utf8"));
const hook = payload.hookSpecificOutput;
if (!hook || hook.hookEventName !== "SessionStart") process.exit(1);
if (typeof hook.additionalContext !== "string") process.exit(1);
if (!hook.additionalContext.includes("You have Octapowers")) process.exit(1);
if (!hook.additionalContext.includes("octapowers:using-octapowers")) process.exit(1);
'
}

assert_claude_payload "$(CLAUDE_PLUGIN_ROOT="$repo_root" bash "$hook")"
assert_claude_payload "$(CLAUDE_PLUGIN_ROOT="$repo_root" bash "$wrapper" session-start)"

echo "PASS: Claude Code SessionStart hook"
