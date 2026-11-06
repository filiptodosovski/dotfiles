#!/usr/bin/env python3
"""Install the AI setup: link repo-owned files, merge app-owned settings, refresh Herdr.

Repo-owned files (skills, status line, sound script) become symlinks into
this checkout, so edits made from either side show up in git. App-owned settings
(JSON the agents also write) are merged: only the keys saved here are enforced,
and everything else in the live file is preserved. Codex files are created only
when missing. Herdr's integration hooks are installed by Herdr itself.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import tempfile
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AI = ROOT / "ai"
SHARED_SKILLS = AI / "skills"


# --- JSON helpers -----------------------------------------------------------


def read_json(path):
    value = json.loads(path.read_text()) if path.exists() else {}
    if not isinstance(value, dict):
        raise TypeError(f"Expected a JSON object: {path}")
    return value


def package_name(entry):
    source = entry.get("source", "") if isinstance(entry, dict) else entry
    if not isinstance(source, str):
        raise TypeError("Invalid Pi package declaration")
    if source.startswith("npm:") and "@" in source[5:]:
        return source.rsplit("@", 1)[0]
    return source


def satisfied(current, desired):
    """True when `current` already contains everything `desired` asks for."""
    if isinstance(desired, dict):
        return isinstance(current, dict) and all(
            key in current and satisfied(current[key], value)
            for key, value in desired.items()
        )
    if isinstance(desired, list):
        return isinstance(current, list) and all(
            any(satisfied(item, wanted) for item in current) for wanted in desired
        )
    if isinstance(desired, str) and desired.startswith("npm:"):
        # `pi update` drops version pins; the same package unpinned still counts.
        return isinstance(current, (str, dict)) and package_name(
            current
        ) == package_name(desired)
    return current == desired


def merge(current, incoming):
    if isinstance(current, dict) and isinstance(incoming, dict):
        result = dict(current)
        for key, value in incoming.items():
            result[key] = merge(current[key], value) if key in current else value
        return result
    if isinstance(current, list) and isinstance(incoming, list):
        return current + [
            wanted
            for wanted in incoming
            if not any(satisfied(item, wanted) for item in current)
        ]
    return incoming


def merge_pi(current, incoming):
    result = merge(current, {k: v for k, v in incoming.items() if k != "packages"})
    replacements = {package_name(p): p for p in incoming.get("packages", [])}
    packages = []
    for entry in current.get("packages", []):
        replacement = replacements.pop(package_name(entry), None)
        if replacement and isinstance(entry, dict):
            entry = {**entry, "source": replacement}
        elif replacement:
            entry = replacement
        packages.append(entry)
    result["packages"] = packages + list(replacements.values())
    return result


def hook_script(command):
    match = re.search(r"\.claude/[\w.-]+", command or "")
    return match.group(0) if match else command


def merge_claude(current, incoming):
    result = merge(current, {k: v for k, v in incoming.items() if k != "hooks"})
    hooks = dict(current.get("hooks", {}))
    for event, desired in incoming.get("hooks", {}).items():
        # Replace an older form of one of our hooks (same script, other arguments).
        ours = {hook_script(h["command"]) for group in desired for h in group["hooks"]}
        groups = []
        for existing in hooks.get(event, []):
            group = dict(existing)
            group["hooks"] = [
                h
                for h in group.get("hooks", [])
                if hook_script(h.get("command")) not in ours
            ]
            if group["hooks"]:
                groups.append(group)
        hooks[event] = groups + desired
    result["hooks"] = hooks
    return result


# --- Plan -------------------------------------------------------------------
# Each step is (kind, target, payload):
#   link    payload = source path in this repo
#   json    payload = (desired dict, merger)
#   seed    payload = source path; written only when the target is missing
#   unlink  payload = None; a dangling link that points into this repo


def check_parents(path, home):
    for parent in path.parents:
        if parent == home:
            break
        if parent.is_symlink():
            raise ValueError(f"Refusing to write through a directory symlink: {parent}")
        if parent.exists() and not parent.is_dir():
            raise ValueError(f"Expected a parent directory: {parent}")


def skill_dirs(base):
    return sorted(p.parent for p in base.glob("*/SKILL.md"))


def links_into(directory, sources):
    steps = [("link", directory / source.name, source) for source in sources]
    # Remove links left behind by skills that were deleted from the repo.
    if directory.is_dir():
        for entry in sorted(directory.iterdir()):
            if (
                entry.is_symlink()
                and not entry.exists()
                and AI in Path(os.readlink(entry)).parents
            ):
                steps.append(("unlink", entry, None))
    return steps


def claude_plan(home):
    claude = home / ".claude"
    return [
        (
            "json",
            claude / "settings.json",
            (read_json(AI / "claude/settings.json"), merge_claude),
        ),
        ("link", claude / "statusline.py", AI / "claude/statusline.py"),
        ("link", claude / "notify.sh", AI / "claude/notify.sh"),
        *links_into(claude / "skills", skill_dirs(SHARED_SKILLS)),
    ]


def build_plan(home, claude_only=False):
    steps = claude_plan(home)
    if not claude_only:
        pi = home / ".pi/agent"
        codex = home / ".codex"
        steps += [
            (
                "json",
                pi / "settings.json",
                (read_json(AI / "pi/settings.json"), merge_pi),
            ),
            *links_into(pi / "skills", skill_dirs(SHARED_SKILLS)),
            ("seed", codex / "config.toml", AI / "codex/config.toml"),
            ("seed", codex / "keybindings.json", AI / "codex/keybindings.json"),
        ]
    for kind, target, _ in steps:
        check_parents(target, home)
        if kind in ("json", "seed") and target.is_dir() and not target.is_symlink():
            raise ValueError(f"Expected a file destination: {target}")
    return steps


def pending(step):
    kind, target, payload = step
    if kind == "link":
        return not (target.is_symlink() and target.resolve() == payload.resolve())
    if kind == "json":
        desired, _ = payload
        return target.is_symlink() or not satisfied(read_json(target), desired)
    if kind == "seed":
        return not target.exists() and not target.is_symlink()
    return kind == "unlink"


def write_atomic(path, content, mode):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            dir=path.parent, prefix=".dotfiles-", delete=False
        ) as handle:
            temporary = Path(handle.name)
            handle.write(content)
        temporary.chmod(mode)
        os.replace(temporary, path)
    finally:
        if temporary and temporary.exists():
            temporary.unlink()


def apply_plan(home, steps):
    parent = home / ".dotfiles-backup"
    if parent.is_symlink() or (parent.exists() and not parent.is_dir()):
        raise ValueError(f"Expected a real backup directory: {parent}")
    backup = None

    def backup_path(path):
        nonlocal backup
        if backup is None:
            parent.mkdir(parents=True, exist_ok=True)
            backup = Path(
                tempfile.mkdtemp(
                    prefix=f"ai-{datetime.now():%Y%m%d-%H%M%S}-", dir=parent
                )
            )
        destination = backup / path.relative_to(home)
        destination.parent.mkdir(parents=True, exist_ok=True)
        return destination

    for step in steps:
        if not pending(step):
            continue
        kind, target, payload = step
        exists = target.exists() or target.is_symlink()
        if kind == "unlink":
            target.unlink()
        elif kind == "link":
            if exists:
                shutil.move(str(target), backup_path(target))
            target.parent.mkdir(parents=True, exist_ok=True)
            target.symlink_to(payload)
        else:
            if exists:
                shutil.copy2(target, backup_path(target), follow_symlinks=False)
            if kind == "json":
                desired, merger = payload
                current = {} if target.is_symlink() else read_json(target)
                content = json.dumps(merger(current, desired), indent=2) + "\n"
                write_atomic(target, content.encode(), 0o600)
            else:
                write_atomic(target, payload.read_bytes(), 0o600)
    return backup


# --- Extras -----------------------------------------------------------------


def herdr_pending(claude_only=False):
    """Agents whose Herdr integration is missing or older than the installed Herdr."""
    if not shutil.which("herdr"):
        return []
    agents = ["claude"] if claude_only else ["pi", "codex", "claude"]
    agents = [a for a in agents if shutil.which(a)]
    try:
        output = subprocess.run(
            ["herdr", "integration", "status"],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        ).stdout
    except (OSError, subprocess.TimeoutExpired):
        return []
    status = {}
    for line in output.splitlines():
        name, _, rest = line.partition(": ")
        status[name.strip()] = rest.split(" (/")[0].strip()
    return [
        (a, status[a])
        for a in agents
        if a in status and not status[a].startswith("current")
    ]


def codex_notes(home):
    """Portable Codex keys that differ from the live config (informational only)."""
    try:
        import tomllib
    except ImportError:
        return []
    live = home / ".codex/config.toml"
    if not live.is_file():
        return []
    try:
        current = tomllib.loads(live.read_text())
    except (tomllib.TOMLDecodeError, OSError):
        return [f"{live} is not valid TOML"]
    desired = tomllib.loads((AI / "codex/config.toml").read_text())
    return [
        f"codex {key}: live {current.get(key)!r}, repo {value!r}"
        for key, value in desired.items()
        if not isinstance(value, dict) and current.get(key) != value
    ]


def shown(path, home):
    try:
        return "~/" + str(path.relative_to(home))
    except ValueError:
        return str(path)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument(
        "--apply",
        action="store_true",
        help="Make the changes; back up replaced files first",
    )
    mode.add_argument(
        "--check",
        action="store_true",
        help="Read-only; exit 1 when anything needs restoring",
    )
    mode.add_argument("--dry-run", action="store_true", help="Print the plan (default)")
    parser.add_argument(
        "--claude-only",
        action="store_true",
        help="Only Claude settings, status line, sounds, skills, and its Herdr hook",
    )
    args = parser.parse_args()
    home = Path.home().resolve()
    labels = {
        "link": "link",
        "json": "merge",
        "seed": "create",
        "unlink": "remove",
    }
    try:
        steps = build_plan(home, claude_only=args.claude_only)
        todo = [step for step in steps if pending(step)]
        herdr = herdr_pending(args.claude_only)
        prefix = "" if args.apply else ("DIFF  " if args.check else "would ")
        for kind, target, _ in todo:
            print(f"{prefix}{labels[kind]:<7} {shown(target, home)}")
        for agent, state in herdr:
            print(f"{prefix}herdr   {agent} integration ({state})")
        if not args.apply:
            for note in codex_notes(home):
                print(f"note    {note}")
            if not todo and not herdr:
                print("AI setup is up to date.")
            return 1 if args.check and (todo or herdr) else 0
        backup = apply_plan(home, todo)
        if backup:
            print(f"Previous files: {shown(backup, home)}")
        for agent, _ in herdr:
            subprocess.run(["herdr", "integration", "install", agent], check=True)
        print("Done. Restart running agents (Pi: /reload) to pick up changes.")
        if not args.claude_only:
            print(
                "Sign into model providers separately. Pi installs its extensions on first start."
            )
        return 0
    except (ValueError, TypeError, OSError, subprocess.CalledProcessError) as error:
        print(f"AI setup failed: {error}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
