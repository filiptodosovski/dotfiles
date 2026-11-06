import contextlib
import hashlib
import importlib.util
import io
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("ai_setup", ROOT / "scripts/ai-setup.py")
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)

SKILLS = sorted(p.parent.name for p in (ROOT / "ai/skills").glob("*/SKILL.md"))


class RestoreTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.home = Path(self.temporary.name).resolve() / "home"
        self.home.mkdir()
        # Never touch the real Herdr installation from tests.
        herdr = patch.object(setup, "herdr_pending", return_value=[])
        herdr.start()
        self.addCleanup(herdr.stop)

    def write_json(self, relative, value):
        target = self.home / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(json.dumps(value))
        return target

    def run_main(self, *arguments):
        output = io.StringIO()
        with (
            patch.object(setup.Path, "home", return_value=self.home),
            patch.object(sys, "argv", ["ai-setup.py", *arguments]),
            contextlib.redirect_stdout(output),
        ):
            code = setup.main()
        self.output = output.getvalue()
        return code

    def apply(self, claude_only=False):
        return setup.apply_plan(self.home, setup.build_plan(self.home, claude_only))

    def test_default_is_read_only(self):
        self.assertEqual(self.run_main(), 0)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_owned_files_are_linked_into_the_repo(self):
        self.apply()
        for relative, source in (
            (".claude/statusline.py", "ai/claude/statusline.py"),
            (".claude/notify.sh", "ai/claude/notify.sh"),
        ):
            target = self.home / relative
            self.assertTrue(target.is_symlink(), relative)
            self.assertEqual(target.resolve(), (ROOT / source).resolve())
        for name in SKILLS:
            for base in (".claude/skills", ".pi/agent/skills"):
                link = self.home / base / name
                self.assertTrue(link.is_symlink(), link)
                self.assertTrue((link / "SKILL.md").is_file())

    def test_existing_copies_are_moved_to_backup_before_linking(self):
        old = self.home / ".claude/skills/impeccable/SKILL.md"
        old.parent.mkdir(parents=True)
        old.write_text("old copy")
        backup = self.apply()
        self.assertTrue((self.home / ".claude/skills/impeccable").is_symlink())
        self.assertEqual(
            (backup / ".claude/skills/impeccable/SKILL.md").read_text(), "old copy"
        )

    def test_restore_backs_up_and_preserves_private_and_extra_settings(self):
        before = {
            "deviceId": "local-device",
            "powerline": {"path": {"custom": "retain"}},
            "packages": [
                {"source": "npm:pi-subagents", "skills": []},
                "npm:another-package",
            ],
        }
        settings = self.write_json(".pi/agent/settings.json", before)
        auth = self.write_json(".pi/agent/auth.json", {"test": "private-fixture"})
        codex = self.home / ".codex/config.toml"
        codex.parent.mkdir()
        codex.write_text('model = "my-existing-model"\n')
        extra = self.home / ".pi/agent/skills/my-own/SKILL.md"
        extra.parent.mkdir(parents=True)
        extra.write_text("My own skill")
        backup = self.apply()
        after = json.loads(settings.read_text())
        self.assertEqual(after["deviceId"], "local-device")
        self.assertEqual(after["powerline"]["path"]["custom"], "retain")
        self.assertEqual(after["packages"][0]["skills"], [])
        self.assertIn("npm:another-package", after["packages"])
        self.assertEqual(
            json.loads((backup / ".pi/agent/settings.json").read_text()), before
        )
        self.assertEqual(settings.stat().st_mode & 0o777, 0o600)
        self.assertEqual(json.loads(auth.read_text()), {"test": "private-fixture"})
        self.assertEqual(codex.read_text(), 'model = "my-existing-model"\n')
        self.assertEqual(extra.read_text(), "My own skill")
        self.assertFalse(extra.parent.is_symlink())

    def test_codex_files_are_only_created_when_missing(self):
        self.apply()
        self.assertEqual(
            (self.home / ".codex/config.toml").read_bytes(),
            (ROOT / "ai/codex/config.toml").read_bytes(),
        )
        self.assertFalse((self.home / ".codex/hooks.json").exists())

    def test_second_restore_is_idempotent(self):
        self.apply()
        self.assertEqual(
            [s for s in setup.build_plan(self.home) if setup.pending(s)], []
        )
        self.assertIsNone(self.apply())
        self.assertEqual(self.run_main("--check"), 0)

    def test_unpinned_packages_and_app_keys_do_not_count_as_drift(self):
        # `pi update` drops version pins and Pi adds its own runtime keys.
        self.apply()
        settings = self.home / ".pi/agent/settings.json"
        current = json.loads(settings.read_text())
        current["packages"] = [setup.package_name(p) for p in current["packages"]]
        current["deviceId"] = "abc"
        current["lastChangelogVersion"] = "9.9.9"
        settings.write_text(json.dumps(current))
        settings.chmod(0o644)
        self.assertEqual(self.run_main("--check"), 0, self.output)

    def test_changed_preference_is_reported_and_restored(self):
        self.apply()
        settings = self.home / ".pi/agent/settings.json"
        current = json.loads(settings.read_text())
        current["defaultThinkingLevel"] = "low"
        settings.write_text(json.dumps(current))
        self.assertEqual(self.run_main("--check"), 1)
        self.assertIn(".pi/agent/settings.json", self.output)
        self.assertEqual(self.run_main("--apply"), 0)
        self.assertEqual(
            json.loads(settings.read_text())["defaultThinkingLevel"],
            setup.read_json(ROOT / "ai/pi/settings.json")["defaultThinkingLevel"],
        )

    def test_dangling_links_into_the_repo_are_removed(self):
        self.apply()
        stale = self.home / ".claude/skills/deleted-skill"
        stale.symlink_to(setup.SHARED_SKILLS / "deleted-skill")
        mine = self.home / ".claude/skills/elsewhere"
        mine.symlink_to(self.home / "missing-but-not-ours")
        self.assertEqual(self.run_main("--check"), 1)
        self.assertEqual(self.run_main("--apply"), 0)
        self.assertFalse(stale.is_symlink())
        self.assertTrue(mine.is_symlink())

    def test_backup_symlink_is_rejected_before_writing(self):
        outside = self.home.parent / "outside"
        outside.mkdir()
        (self.home / ".dotfiles-backup").symlink_to(outside, target_is_directory=True)
        self.assertEqual(self.run_main("--apply"), 1)
        self.assertFalse((self.home / ".pi").exists())
        self.assertEqual(list(outside.iterdir()), [])

    def test_invalid_json_fails_before_any_restore(self):
        settings = self.home / ".pi/agent/settings.json"
        settings.parent.mkdir(parents=True)
        settings.write_text("{malformed")
        self.assertEqual(self.run_main("--apply"), 1)
        self.assertFalse((self.home / ".pi/agent/skills").exists())
        self.assertFalse((self.home / ".claude").exists())
        self.assertFalse((self.home / ".dotfiles-backup").exists())

    def test_directory_symlinks_are_not_followed(self):
        outside = self.home.parent / "outside"
        outside.mkdir()
        (self.home / ".pi").symlink_to(outside, target_is_directory=True)
        with self.assertRaisesRegex(ValueError, "directory symlink"):
            setup.build_plan(self.home)
        self.assertEqual(list(outside.iterdir()), [])

    def test_directory_at_file_destination_fails_before_restoring(self):
        (self.home / ".claude/settings.json").mkdir(parents=True)
        self.assertEqual(self.run_main("--apply"), 1)
        self.assertFalse((self.home / ".pi").exists())

    def test_check_reports_missing_files_without_writing(self):
        self.assertEqual(self.run_main("--check"), 1)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_herdr_updates_are_reported_by_check(self):
        with patch.object(
            setup, "herdr_pending", return_value=[("codex", "outdated (v8 < v10)")]
        ):
            self.apply()
            self.assertEqual(self.run_main("--check"), 1)
        self.assertIn("codex integration (outdated", self.output)

    def test_claude_only_preserves_other_hooks_permissions_and_skills(self):
        settings = self.write_json(
            ".claude/settings.json",
            {
                "permissions": {"defaultMode": "default", "allow": ["Bash(make *)"]},
                "hooks": {
                    "SessionStart": [
                        {"hooks": [{"type": "command", "command": "my-herdr-hook"}]}
                    ],
                    "Stop": [
                        {"hooks": [{"type": "command", "command": "my-existing-stop"}]},
                        # The previous form of our own hook must be replaced, not kept.
                        {
                            "hooks": [
                                {
                                    "type": "command",
                                    "command": 'sh "$HOME/.claude/notify.sh"',
                                    "async": True,
                                }
                            ]
                        },
                    ],
                },
            },
        )
        extra = self.home / ".claude/skills/my-existing/SKILL.md"
        extra.parent.mkdir(parents=True)
        extra.write_text("Keep this skill")
        self.assertEqual(self.run_main("--claude-only", "--apply"), 0)
        self.assertFalse((self.home / ".pi").exists())
        self.assertFalse((self.home / ".codex").exists())
        current = json.loads(settings.read_text())
        self.assertEqual(current["permissions"]["defaultMode"], "default")
        self.assertEqual(current["permissions"]["allow"][0], "Bash(make *)")
        self.assertIn("Bash(git status *)", current["permissions"]["allow"])
        self.assertEqual(
            current["hooks"]["SessionStart"][0]["hooks"][0]["command"], "my-herdr-hook"
        )
        stop = [h["command"] for g in current["hooks"]["Stop"] for h in g["hooks"]]
        self.assertEqual(
            stop, ["my-existing-stop", 'sh "$HOME/.claude/notify.sh" done']
        )
        self.assertEqual(extra.read_text(), "Keep this skill")
        self.assertEqual(self.run_main("--claude-only", "--apply"), 0)
        current = json.loads(settings.read_text())
        self.assertEqual(len(current["hooks"]["Stop"]), 2)
        self.assertEqual(current["permissions"]["allow"].count("Bash(git status *)"), 1)
        self.assertEqual(self.run_main("--claude-only", "--check"), 0)


class RepoTests(unittest.TestCase):
    def test_manual_only_flags(self):
        manual = [
            name
            for name in SKILLS
            if "disable-model-invocation: true"
            in (ROOT / "ai/skills" / name / "SKILL.md").read_text()
        ]
        self.assertEqual(manual, ["grill-me"])

    def test_every_saved_skill_has_a_recorded_source(self):
        sources = json.loads((ROOT / "ai/skills/sources.json").read_text())["skills"]
        self.assertLessEqual(set(SKILLS), set(sources))

    def test_skill_entries_match_recorded_upstream_except_updated_impeccable(self):
        sources = json.loads((ROOT / "ai/skills/sources.json").read_text())["skills"]
        for name in SKILLS:
            if name != "impeccable":
                digest = hashlib.sha256(
                    (ROOT / "ai/skills" / name / "SKILL.md").read_bytes()
                ).hexdigest()
                self.assertEqual(digest, sources[name]["entrySha256"], name)

    def test_no_runtime_or_credential_files_in_repo(self):
        forbidden = {
            "auth.json",
            "mcp-auth.json",
            "models.json",
            "models-store.json",
            "session.json",
            "credentials.json",
        }
        for path in (ROOT / "ai").rglob("*"):
            self.assertNotIn(path.name, forbidden, str(path))
            self.assertNotIn("node_modules", path.parts, str(path))
        settings = json.loads((ROOT / "ai/pi/settings.json").read_text())
        self.assertNotIn("deviceId", settings)
        # Skills are symlinked, so Impeccable downloads its engine into the repo;
        # git must ignore it.
        ignored = subprocess.run(
            [
                "git",
                "-C",
                str(ROOT),
                "check-ignore",
                "-q",
                "ai/skills/impeccable/scripts/bin/engine",
            ],
            check=False,
        )
        self.assertEqual(ignored.returncode, 0)

    def test_extension_packages_are_pinned(self):
        # Pi installs exactly these versions on start; no lockfile is kept here.
        settings = json.loads((ROOT / "ai/pi/settings.json").read_text())
        for source in settings["packages"]:
            self.assertRegex(source, r"^npm:[\w@/.-]+@\d+\.\d+\.\d+$")


if __name__ == "__main__":
    unittest.main()
