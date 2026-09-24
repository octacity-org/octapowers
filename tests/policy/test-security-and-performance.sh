#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
router="$repo_root/skills/using-octapowers/SKILL.md"
security="$repo_root/skills/security-review/SKILL.md"
security_metadata="$repo_root/skills/security-review/agents/openai.yaml"
performance="$repo_root/skills/performance-investigation/SKILL.md"
performance_metadata="$repo_root/skills/performance-investigation/agents/openai.yaml"

assert_contains() {
  local file="$1"
  local pattern="$2"
  if ! grep -Fq -- "$pattern" "$file"; then
    echo "FAIL: expected '$pattern' in $file" >&2
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

assert_contains "$router" 'Security-sensitive implementation, an explicit security assessment, or a targeted security property: use `security-review`.'
assert_contains "$router" 'Performance problems, explicit optimization work, or a specific metric target: use `performance-investigation`.'

assert_contains "$security" "name: security-review"
assert_contains "$security" "Targeted analysis:"
assert_contains "$security" "Change-focused review:"
assert_contains "$security" "Broad assessment:"
assert_contains "$security" "Do not silently broaden a targeted request into a repository-wide audit."
assert_contains "$security" "authorization"
assert_contains "$security" "trust boundaries"
assert_contains "$security" "privileges, credentials, network reach, and capabilities"
assert_contains "$security" "Inspect relevant callers and alternate entry points."
assert_contains "$security" "previous and new trust model"
assert_contains "$security" "eventual interpreter and sensitive sink"
assert_contains "$security" "business rules, quotas, pricing, currencies, ownership transfers, approval workflows"
assert_contains "$security" "attacker-controlled loops, recursion, parsing or decompression depth"
assert_contains "$security" "first-party code from generated, vendored, framework, and dependency behavior"
assert_contains "$security" "security-relevant events are attributable and observable"
assert_contains "$security" "earliest authoritative boundary"
assert_contains "$security" "attacker-controlled source or capability"
assert_contains "$security" "missing or ineffective control"
assert_contains "$security" "reachable sensitive operation"
assert_contains "$security" "resulting impact"
assert_contains "$security" "Do not assign severity solely from the vulnerability category."
assert_contains "$security" "Use non-destructive proofs where possible."
assert_contains "$security" "Do not claim that an assessment proves the system is secure."
assert_contains "$security" "Do not implement review findings unless the user requested changes."
assert_contains "$security" "Rank findings by exploitability and impact"
assert_contains "$security_metadata" "Analyze targeted security properties and changes"
assert_contains "$security_metadata" '$security-review'

assert_contains "$performance" "name: performance-investigation"
assert_contains "$performance" "open-ended optimization or a specific performance target"
assert_contains "$performance" "Do not silently weaken a user-specified target."
assert_contains "$performance" "p50, p95, or p99 latency"
assert_contains "$performance" "Small/local:"
assert_contains "$performance" "Moderate:"
assert_contains "$performance" "System-wide:"
assert_contains "$performance" "Establish a Baseline"
assert_contains "$performance" "known-good revision or configuration"
assert_contains "$performance" "Do not draw production conclusions from debug or development builds"
assert_contains "$performance" "work is not optimized away"
assert_contains "$performance" "Do not discard outliers without explaining why."
assert_contains "$performance" "Form one concrete bottleneck hypothesis"
assert_contains "$performance" "Use test-driven development for non-tiny production changes unless the user overrides it."
assert_contains "$performance" "Do not treat a noisy benchmark threshold as an ordinary correctness test"
assert_contains "$performance" "Compare before and after using the same workload"
assert_contains "$performance" "Stop when the stated target is met"
assert_contains "$performance" "best achieved value"
assert_contains "$performance" "Do not claim an improvement without fresh measurements."
assert_contains "$performance" "Preserve correctness"
assert_contains "$performance_metadata" "Measure and satisfy software performance targets"
assert_contains "$performance_metadata" '$performance-investigation'

assert_word_count_at_most "$security" 950
assert_word_count_at_most "$performance" 850

echo "PASS: security and performance skill policy"
