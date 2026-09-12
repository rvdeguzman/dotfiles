"""Doctor tests use fixtures and mocks; no machine configuration is changed."""
import contextlib
import importlib.util
import io
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location(
    "doctor", Path(__file__).resolve().parents[1] / "scripts/doctor.py")
doctor = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(doctor)


class DoctorTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.checker = doctor.Doctor(root=self.root, home=self.root)
        self.output = io.StringIO()
        self.redirect = contextlib.redirect_stdout(self.output)
        self.redirect.__enter__()
        self.addCleanup(self.redirect.__exit__, None, None, None)

    def test_origin_normalization(self):
        for remote in ("https://github.com/rvdeguzman/doom.git",
                       "git@github.com:rvdeguzman/doom.git",
                       "ssh://git@github.com/rvdeguzman/doom.git"):
            self.assertEqual(doctor.canonical_remote(remote), "rvdeguzman/doom")
        self.assertIsNone(doctor.canonical_remote("https://secret@github.com/rvdeguzman/doom.git"))
        self.assertIsNone(doctor.canonical_remote("https://example.com/rvdeguzman/doom.git"))

    def test_reject_parent_repository(self):
        with patch.object(doctor, "run", return_value=(0, str(self.root.parent))):
            self.checker.checkout(self.root)
        self.assertEqual(self.checker.errors, 1)

    def test_wrong_origin_is_not_printed(self):
        with patch.object(doctor, "run", side_effect=[
            (0, str(self.root)), (0, "https://secret@example.com/repo"), (0, "")
        ]):
            self.checker.checkout(self.root, "https://github.com/rvdeguzman/doom.git")
        self.assertEqual(self.checker.errors, 1)
        self.assertNotIn("secret@", self.output.getvalue())

    def test_dirty_paths_suppressed(self):
        with patch.object(doctor, "run", side_effect=[
            (0, str(self.root)), (0, "?? private-history")
        ]):
            self.checker.checkout(self.root)
        self.assertEqual(self.checker.warnings, 1)
        self.assertNotIn("private-history", self.output.getvalue())

    @unittest.skipIf(doctor.tomllib is None, "needs Python 3.11 TOML support")
    def test_external_manifest_drives_checks(self):
        (self.root / "home").mkdir()
        (self.root / "home/.chezmoiexternal.toml").write_text(
            '[".config/example"]\ntype = "git-repo"\nurl = "https://github.com/u/r.git"\n')
        with patch.object(self.checker, "checkout") as checkout:
            self.checker.externals()
        checkout.assert_called_once_with(self.root / ".config/example", "https://github.com/u/r.git")

    def test_old_python_reports_skip(self):
        with patch.object(doctor, "tomllib", None):
            self.checker.externals()
        self.assertEqual(self.checker.warnings, 1)

    def test_drift_safe_flags_and_suppression(self):
        with patch.object(self.checker, "command", return_value="chezmoi"), \
             patch.object(doctor, "run", side_effect=[
                 (0, str(self.root / "home")), (0, "MM private-file")
             ]) as run:
            self.checker.drift()
        args = run.call_args.args
        self.assertIn("--refresh-externals=never", args)
        self.assertIn("--dry-run", args)
        self.assertIn("--skip-secrets", args)
        self.assertIn("--exclude=externals", args)
        self.assertNotIn("private-file", self.output.getvalue())

    def test_other_chezmoi_source_skips_status(self):
        with patch.object(self.checker, "command", return_value="chezmoi"), \
             patch.object(doctor, "run", return_value=(0, "/different/source")) as run:
            self.checker.drift()
        self.assertEqual(run.call_count, 1)
        self.assertEqual(self.checker.warnings, 1)

    def test_timeout_is_failure(self):
        with patch.object(doctor.subprocess, "run", side_effect=subprocess.TimeoutExpired("git", 30)):
            self.assertEqual(doctor.run("git"), (1, ""))

    def test_missing_packages_no_bundle(self):
        directory = self.root / "packages/macos"
        directory.mkdir(parents=True)
        (directory / "Brewfile").write_text('brew "tap/repo/emacs-mac@29"\nbrew "fd"\ncask "ghostty"\n')
        with patch.object(doctor, "run", side_effect=[(0, "emacs-mac@29"), (1, ""), (0, "ghostty")]) as run:
            self.checker.packages()
        self.assertEqual(self.checker.warnings, 1)
        self.assertIn("Missing Brewfile brew packages: fd", self.output.getvalue())
        for call in run.call_args_list:
            self.assertIn(call.args[:2], (("brew", "list"), ("brew", "--prefix")))

    def test_formula_alias_is_not_missing(self):
        directory = self.root / "packages/macos"
        directory.mkdir(parents=True)
        (directory / "Brewfile").write_text('brew "python"\n')
        with patch.object(doctor, "run", side_effect=[
            (0, "python@3.14"), (0, "/opt/homebrew/opt/python@3.14"), (0, "")
        ]):
            self.checker.packages()
        self.assertEqual(self.checker.warnings, 0)


if __name__ == "__main__":
    unittest.main()
