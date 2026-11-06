import importlib.util
import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "claude_statusline", ROOT / "ai/claude/statusline.py"
)
status = importlib.util.module_from_spec(spec)
spec.loader.exec_module(status)


class StatuslineTests(unittest.TestCase):
    def render(self, data):
        with (
            patch.dict(os.environ, {"NO_COLOR": "1"}),
            patch.object(status, "git_state", return_value=("main", 0)),
        ):
            return status.render(data)

    def test_metrics_are_readable_and_zero_is_not_treated_as_missing(self):
        text = self.render(
            {
                "workspace": {"current_dir": "/project/web"},
                "model": {"display_name": "Opus"},
                "effort": {"level": "high"},
                "context_window": {"used_percentage": 0},
                "prompt_cache": {"hit_ratio": 0.91},
                "rate_limits": {
                    "five_hour": {"used_percentage": 0},
                    "seven_day": {"used_percentage": 42},
                },
            }
        )
        self.assertEqual(
            text,
            "web [main] · Opus/high | ctx 0% · cache 91% · 5h 0% · wk 42%",
        )
        self.assertNotIn("$", text)

    def test_first_turn_null_fields_are_hidden_not_shown_as_zero(self):
        text = self.render(
            {
                "model": None,
                "context_window": None,
                "rate_limits": None,
                "prompt_cache": None,
            }
        )
        self.assertNotIn("|", text)
        self.assertNotIn("0%", text)
        self.assertNotIn("--", text)

    def test_partial_metrics_show_only_available_values(self):
        text = self.render(
            {
                "context_window": {"used_percentage": 4},
                "prompt_cache": {"hit_ratio": 0.65},
                "rate_limits": {"seven_day": {"used_percentage": 13}},
            }
        )
        self.assertIn("| ctx 4% · cache 65% · wk 13%", text)
        self.assertNotIn("5h", text)

    def test_changed_file_count_follows_branch(self):
        with (
            patch.dict(os.environ, {"NO_COLOR": "1"}),
            patch.object(status, "git_state", return_value=("main", 3)),
        ):
            self.assertIn("[main ±3]", status.render({"cwd": "/project/web"}))

    def test_git_state_reads_branch_detached_head_and_changes(self):
        with tempfile.TemporaryDirectory() as directory:
            git = ["git", "-C", directory, "-c", "user.name=t", "-c", "user.email=t@t"]
            subprocess.run([*git, "init", "-q", "-b", "trunk"], check=True)
            self.assertEqual(status.git_state(directory), ("trunk", 0))
            Path(directory, "a.txt").write_text("a")
            self.assertEqual(status.git_state(directory), ("trunk", 1))
            subprocess.run([*git, "add", "."], check=True)
            subprocess.run([*git, "commit", "-qm", "init"], check=True)
            subprocess.run([*git, "checkout", "-q", "--detach"], check=True)
            branch, changed = status.git_state(directory)
            self.assertTrue(branch.startswith("@"), branch)
            self.assertEqual(changed, 0)

    def test_terminal_controls_are_removed_from_displayed_names(self):
        text = self.render(
            {"cwd": "/project/web\nBAD", "model": {"display_name": "Opus\x1b"}}
        )
        self.assertEqual(len(text.splitlines()), 1)
        self.assertNotIn("\x1b", text)

    def test_non_repository_is_quiet(self):
        with tempfile.TemporaryDirectory() as directory:
            self.assertEqual(status.git_state(directory), ("", 0))
            with patch.dict(os.environ, {"NO_COLOR": "1"}):
                self.assertIn("[no git]", status.render({"cwd": directory}))


if __name__ == "__main__":
    unittest.main()
