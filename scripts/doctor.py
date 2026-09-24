#!/usr/bin/env python3
"""Report visible Octapowers installation files without changing them."""

import hashlib
import json
import os
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
HOME = Path.home()


def read_json(path: Path) -> dict:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return {}
    except (OSError, ValueError) as error:
        print(f"  Cannot read {path}: {error}")
        return {}
    return value if isinstance(value, dict) else {}


def skill_dirs(directory: Path) -> dict[str, Path]:
    if not directory.is_dir():
        return {}
    return {
        path.name: path
        for path in directory.iterdir()
        if path.is_dir() and (path / "SKILL.md").is_file()
    }


def fingerprint(directory: Path) -> dict[str, str]:
    result = {}
    for path in directory.rglob("*"):
        relative = str(path.relative_to(directory))
        if path.is_symlink():
            result[relative] = f"link:{os.readlink(path)}"
        elif path.is_file():
            result[relative] = hashlib.sha256(path.read_bytes()).hexdigest()
    return result


def compare(source: dict[str, Path], installed: dict[str, Path]) -> None:
    missing = sorted(source.keys() - installed.keys())
    changed = sorted(
        name
        for name in source.keys() & installed.keys()
        if fingerprint(source[name]) != fingerprint(installed[name])
    )
    matching = len(source) - len(missing) - len(changed)
    print(f"  Skills matching this checkout: {matching}/{len(source)}")
    if missing:
        print(f"  Missing: {', '.join(missing)}")
    if changed:
        print(f"  Different: {', '.join(changed)}")


def main() -> None:
    manifest = read_json(ROOT / ".codex-plugin/plugin.json")
    marketplace = read_json(ROOT / ".agents/plugins/marketplace.json")
    plugin = manifest.get("name", "octapowers")
    publisher = marketplace.get("name", "0ctacity")
    source = skill_dirs(ROOT / "skills")
    print(f"Octapowers checkout: {manifest.get('version', 'unknown version')}, {len(source)} skills")

    codex_home = Path(os.environ.get("CODEX_HOME", HOME / ".codex"))
    cache = codex_home / "plugins/cache" / publisher / plugin
    copies = sorted(path for path in cache.iterdir() if path.is_dir()) if cache.is_dir() else []
    print("Codex:")
    if not copies:
        print("  No cached Octapowers plugin found")
    for copy in copies:
        cached_manifest = read_json(copy / ".codex-plugin/plugin.json")
        print(f"  Cached copy: {cached_manifest.get('version', copy.name)} ({copy})")
        compare(source, skill_dirs(copy / "skills"))

    registry_path = HOME / ".claude/plugins/installed_plugins.json"
    records = read_json(registry_path).get("plugins", {})
    entry = records.get(f"{plugin}@{publisher}") if isinstance(records, dict) else None
    print("Claude Code:")
    if not entry:
        print("  No Octapowers install record found")
    else:
        installs = entry if isinstance(entry, list) else [entry]
        for install in installs:
            if not isinstance(install, dict) or not install.get("installPath"):
                print("  Install recorded, but no install path is available")
                continue
            path = Path(install["installPath"]).expanduser()
            print(f"  Recorded version: {install.get('version', 'unknown')} ({path})")
            if path.is_dir():
                compare(source, skill_dirs(path / "skills"))
                print(f"  Session-start hook: {'found' if (path / 'hooks/session-start').is_file() else 'missing'}")
            else:
                print("  Recorded install path is missing")

    antigravity_dir = Path(
        os.environ.get("OCTAPOWERS_ANTIGRAVITY_SKILLS_DIR", HOME / ".gemini/config/skills")
    )
    antigravity_rules = Path(
        os.environ.get("OCTAPOWERS_ANTIGRAVITY_RULES", HOME / ".gemini/GEMINI.md")
    )
    managed = antigravity_dir / ".octapowers-managed"
    print("Antigravity:")
    if not managed.is_file():
        print("  No managed Octapowers skill copies found")
    else:
        names = set(managed.read_text(encoding="utf-8").splitlines())
        installed = {name: path for name, path in skill_dirs(antigravity_dir).items() if name in names}
        print(f"  Managed skill copies: {len(installed)}")
        compare(source, installed)
    rules = antigravity_rules.read_text(encoding="utf-8") if antigravity_rules.is_file() else ""
    router = "<!-- octapowers-antigravity:start -->" in rules and "<!-- octapowers-antigravity:end -->" in rules
    print(f"  Router instruction: {'found' if router else 'missing'}")

    shared_dir = Path(os.environ.get("OCTAPOWERS_ZED_SKILLS_DIR", HOME / ".agents/skills"))
    shared_manifest = shared_dir / ".octapowers-managed"
    print("OpenCode and Codebuff shared skills:")
    if not shared_manifest.is_file():
        print("  No managed Octapowers skill copies found")
    else:
        names = set(shared_manifest.read_text(encoding="utf-8").splitlines())
        installed = {name: path for name, path in skill_dirs(shared_dir).items() if name in names}
        print(f"  Managed skill copies: {len(installed)}")
        compare(source, installed)

    opencode_rules = Path(
        os.environ.get("OCTAPOWERS_OPENCODE_AGENTS", HOME / ".config/opencode/AGENTS.md")
    )
    opencode_text = opencode_rules.read_text(encoding="utf-8") if opencode_rules.is_file() else ""
    print(f"OpenCode router: {'found' if '<!-- octapowers-opencode:start -->' in opencode_text else 'missing'}")

    codebuff_override = os.environ.get("OCTAPOWERS_CODEBUFF_RULES")
    codebuff_candidates = [HOME / name for name in (".knowledge.md", ".AGENTS.md", ".CLAUDE.md")]
    codebuff_rules = Path(codebuff_override) if codebuff_override else next(
        (path for path in codebuff_candidates if path.is_file()), codebuff_candidates[0]
    )
    codebuff_text = codebuff_rules.read_text(encoding="utf-8") if codebuff_rules.is_file() else ""
    print(f"Codebuff router: {'found' if '<!-- octapowers-codebuff:start -->' in codebuff_text else 'missing'}")

    print("Note: File detection does not prove an agent loaded or used these skills.")


if __name__ == "__main__":
    main()
