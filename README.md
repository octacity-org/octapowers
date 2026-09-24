# Octapowers

Octapowers is an independent fork of [Superpowers](https://github.com/obra/superpowers) 6.1.1 for the Octacity community. It provides a proportional software-development workflow for Codex, Claude Code, Antigravity, OpenCode, and Codebuff/Freebuff.

It keeps systematic debugging, test-driven development, verification, code review, worktrees, and agent-driven execution while avoiding mandatory specs and written plans for ordinary implementation work.

Octapowers does not track Superpowers upstream. Its workflow, releases, and future development are maintained independently under [`0ctacity/octapowers`](https://github.com/0ctacity/octapowers).

## Supported coding agents

- Codex App and Codex CLI
- Claude Code
- Antigravity IDE
- OpenCode
- Codebuff / Freebuff

Other coding-agent harnesses are not currently supported. Gemini CLI can discover the copies installed for Zed through its `~/.agents/skills` alias, but it is not currently a tested Octapowers integration.

## Install

### Codex

Add the Octapowers marketplace:

```bash
codex plugin marketplace add 0ctacity/octapowers
```

Install Octapowers:

```bash
codex plugin add octapowers@0ctacity
```

Start a new Codex task after installation.

To update later:

```bash
codex plugin marketplace upgrade 0ctacity
codex plugin add octapowers@0ctacity
```

Start another new task so Codex loads the updated plugin.

### Claude Code

Add the Octapowers marketplace:

```text
/plugin marketplace add 0ctacity/octapowers
```

Install Octapowers:

```text
/plugin install octapowers@0ctacity
```

Run `/reload-plugins` after installation so Claude Code activates Octapowers in the current session.

### Antigravity IDE

Clone Octapowers, then install every skill globally:

```bash
git clone https://github.com/0ctacity/octapowers.git
cd octapowers
./scripts/sync-antigravity-skills.sh
```

The script copies the skills to `~/.gemini/config/skills/` and adds a managed Octapowers router instruction to `~/.gemini/GEMINI.md`. Existing unrelated skills and global instructions are preserved. Restart Antigravity after the first installation, then use `/skills` to confirm discovery. Skills can also be invoked explicitly as `/<skill-name>`.

To update later from the cloned repository:

```bash
git pull
./scripts/sync-antigravity-skills.sh
```

### OpenCode and Codebuff / Freebuff

Clone Octapowers, then install the shared global skills and router instructions:

```bash
git clone https://github.com/0ctacity/octapowers.git
cd octapowers
./scripts/sync-opencode-codebuff-skills.sh
```

The script copies skills to `~/.agents/skills/`, which both agents discover. It adds a managed router instruction to OpenCode's `~/.config/opencode/AGENTS.md` and Codebuff's existing home knowledge file (or creates `~/.knowledge.md`). It also disables these shared copies in Codex, so a Codex plugin installation does not see the same skills twice. Unrelated skills and instructions are preserved. Start a new OpenCode or Codebuff session after installation.

To update later, run `git pull` in the clone and rerun `./scripts/sync-opencode-codebuff-skills.sh`.

## Workflow

Moderate autonomous execution is the default:

1. Inspect the relevant project context.
2. Form an internal approach when useful.
3. Implement the requested change.
4. Verify the result in proportion to risk.
5. Report the outcome and any genuine uncertainty.

Large or ambitious requests do not automatically create written artifacts or approval gates. Written designs and implementation plans are opt-in: when explicitly requested, they are written for review and require approval before the next gated stage.

## Included skills

- `using-octapowers`: proportional workflow routing
- `brainstorming`: conversational exploration or opt-in written design
- `show-me`: explicit, focused visual explanations
- `inspecting-github-work`: read-only issue and pull-request orientation
- `reviewing-github-pr`: file-by-file PR review, with optional GitHub submission and inline comments
- `creating-github-work`: evidence-based issue and pull-request creation
- `fixing-github-work`: scoped implementation from issues and pull requests
- `language-style`: compact, project-compatible conventions for supported languages
- `writing-plans`: opt-in written implementation plans
- `systematic-debugging`
- `security-review`
- `performance-investigation`
- `test-driven-development`
- `verification-before-completion`
- `requesting-code-review`
- `receiving-code-review`
- `dispatching-parallel-agents`
- `subagent-driven-development`
- `executing-plans`
- `using-git-worktrees`
- `finishing-a-development-branch`
- `writing-skills`

## Installation doctor

To inspect local installation files without changing them:

```bash
python3 scripts/doctor.py
```

The doctor compares cached or copied skills with this checkout; it cannot confirm that an agent loaded them.

## Development checks

Run the proportional-routing policy test:

```bash
tests/policy/test-proportional-workflow.sh
```

The repository also contains Codex packaging tests, Claude Code integration tests, shell lint checks, and brainstorming companion tests.

## License and attribution

Octapowers is an independent fork of Jesse Vincent's Superpowers 6.1.1. It is maintained by Octacity and remains available under the MIT License. See [LICENSE](LICENSE).
