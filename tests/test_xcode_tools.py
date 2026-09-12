"""Exercise the updater with fake tools; never install or scan real updates."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "update-xcode-tools"
LABEL = "Command Line Tools for Xcode-26.0"


class XcodeToolsTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.env = dict(os.environ, PATH=f"{self.root}:{os.environ['PATH']}")
        self.tool("uname", "echo Darwin")
        self.tool("xcode-select", 'echo "xcode-select $*" >> "$LOG"; echo /Developer')
        self.tool("xcrun", "echo /SDK")
        self.tool("clang", "echo clang")
        self.tool("softwareupdate", 'printf "%s\\n" "$LISTING"; exit "${SCAN_STATUS:-0}"')
        self.tool("sudo", 'printf "%s\\n" "$@" >> "$LOG"')
        self.env.update(LOG=str(self.root / "log"), LISTING=(
            f"* Label: {LABEL}\n* Label: macOS Update-27.0\n"
        ))

    def tool(self, name, body):
        path = self.root / name
        path.write_text("#!/bin/bash\n" + body + "\n")
        path.chmod(0o755)

    def run_tool(self, *args, answer=""):
        return subprocess.run([str(SCRIPT), *args], input=answer, text=True,
                              capture_output=True, env=self.env)

    def log(self):
        path = self.root / "log"
        return path.read_text() if path.exists() else ""

    def test_check_filters_os_updates(self):
        result = self.run_tool()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(LABEL, result.stdout)
        self.assertNotIn("macOS Update", result.stdout)
        self.assertNotIn("--install", self.log())

    def test_install_exact_label(self):
        result = self.run_tool("--install", LABEL, answer="y\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f"softwareupdate\n--install\n{LABEL}\n", self.log())

    def test_refuse_os_and_unknown_labels(self):
        for label in ("macOS Update-27.0", "Command Line Tools missing", "--all"):
            self.assertNotEqual(self.run_tool("--install", label, answer="y\n").returncode, 0)
        self.assertNotIn("--install", self.log())

    def test_cancel(self):
        self.assertEqual(self.run_tool("--install", LABEL, answer="n\n").returncode, 0)
        self.assertNotIn("--install", self.log())

    def test_scan_failure(self):
        self.env["SCAN_STATUS"] = "1"
        self.assertNotEqual(self.run_tool().returncode, 0)

    def test_no_updates(self):
        self.env["LISTING"] = "No new software available."
        self.assertIn("No Command Line Tools update labels", self.run_tool().stdout)

    def test_non_macos(self):
        self.tool("uname", "echo Linux")
        self.assertNotEqual(self.run_tool().returncode, 0)
        self.assertEqual(self.log(), "")

    def test_bootstrap_missing_tools(self):
        self.tool("xcode-select", '[[ $1 == --install ]] || exit 1; echo bootstrap >> "$LOG"')
        self.assertEqual(self.run_tool("--bootstrap").returncode, 0)
        self.assertIn("bootstrap", self.log())

    def test_bootstrap_preserves_existing_selection(self):
        self.assertEqual(self.run_tool("--bootstrap").returncode, 0)
        self.assertNotIn("--install", self.log())

    def test_install_failure_propagates(self):
        self.tool("sudo", "exit 7")
        self.assertEqual(self.run_tool("--install", LABEL, answer="y\n").returncode, 7)

    def test_requires_label(self):
        self.assertEqual(self.run_tool("--install").returncode, 2)


if __name__ == "__main__":
    unittest.main()
