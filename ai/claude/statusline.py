"""Render Claude's supplied session metrics locally; no API calls or credentials."""

import json
import math
import os
import subprocess
import sys
from pathlib import Path


def number(value):
    if (
        isinstance(value, (int, float))
        and not isinstance(value, bool)
        and math.isfinite(value)
    ):
        return value
    return None


def clean(value, limit=48):
    return "".join(c for c in str(value) if c.isprintable())[:limit]


def git_state(cwd):
    """Return (branch, changed_files) from one quick git call; ("", 0) outside git."""
    try:
        result = subprocess.run(
            ["git", "-C", cwd, "status", "--porcelain=v2", "--branch"],
            check=False,
            capture_output=True,
            text=True,
            timeout=0.5,
            env={**os.environ, "GIT_OPTIONAL_LOCKS": "0"},
        )
    except (OSError, subprocess.TimeoutExpired):
        return "", 0
    if result.returncode != 0:
        return "", 0
    head = oid = ""
    changed = 0
    for line in result.stdout.splitlines():
        if line.startswith("# branch.head "):
            head = line.split(" ", 2)[2]
        elif line.startswith("# branch.oid "):
            oid = line.split(" ", 2)[2]
        elif not line.startswith("#"):
            changed += 1
    if head and head != "(detached)":
        return clean(head, 20), changed
    # A detached worktree has a commit but no symbolic branch name.
    return ("@" + clean(oid, 7) if oid and oid != "(initial)" else "@new"), changed


def render(data):
    workspace = data.get("workspace") or {}
    cwd = workspace.get("current_dir") or data.get("cwd") or str(Path.cwd())
    folder = "~" if Path(cwd) == Path.home() else Path(cwd).name or cwd
    git_branch, changed = git_state(cwd)
    if git_branch and changed:
        git_branch += f" ±{changed}"
    identity = [f"{clean(folder, 20)} [{git_branch or 'no git'}]"]
    model = data.get("model") or {}
    model_name = clean(model.get("display_name") or model.get("id") or "Claude", 24)
    effort = (data.get("effort") or {}).get("level")
    if effort:
        effort = {"medium": "med", "minimal": "min"}.get(effort, effort)
        model_name += "/" + clean(effort, 8)
    identity.append(model_name)

    context = data.get("context_window") or {}
    used = number(context.get("used_percentage"))
    # Metrics Claude hasn't supplied yet are left out instead of shown as zero.
    metrics = [f"ctx {used:.0f}%"] if used is not None else []
    cache = data.get("prompt_cache") or {}
    ratio = number(cache.get("hit_ratio"))
    if ratio is not None:
        metrics.append(f"cache {min(1, max(0, ratio)) * 100:.0f}%")
    # Account limits are optional and supplied by Claude after an API response.
    limits = data.get("rate_limits") or {}
    for key, label in (("five_hour", "5h"), ("seven_day", "wk")):
        percentage = number((limits.get(key) or {}).get("used_percentage"))
        if percentage is not None:
            metrics.append(f"{label} {percentage:.0f}%")

    # Colors match the shared terminal palette; no special font glyphs required.
    first = " · ".join(identity)
    second = " · ".join(metrics)
    if "NO_COLOR" in os.environ:
        return first + (" | " + second if second else "")
    line = f"\033[38;2;152;176;194m{first}\033[0m"
    if second:
        line += f" | \033[38;2;164;172;182m{second}\033[0m"
    return line


def main():
    try:
        data = json.load(sys.stdin)
        if not isinstance(data, dict):
            data = {}
    except (ValueError, OSError):
        data = {}
    print(render(data))


if __name__ == "__main__":
    main()
