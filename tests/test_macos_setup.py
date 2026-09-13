"""Installer platform guards and macOS command routing, without real installs."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class MacosSetupTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.env = dict(os.environ, PATH=f"{self.root}:{os.environ['PATH']}",
                        LOG=str(self.root / "log"))
        self.tool("uname", "echo Darwin")
        for name in ("brew", "chezmoi", "npm", "curl", "herdr"):
            self.tool(name, f'printf "%s\\n" "{name} $*" >> "$LOG"')

    def tool(self, name, body):
        path = self.root / name
        path.write_text("#!/bin/bash\n" + body + "\n")
        path.chmod(0o755)

    def run_script(self, name, *args):
        return subprocess.run([str(ROOT / name), *args], capture_output=True,
                              text=True, env=self.env)

    def test_all_installers_reject_non_macos_before_mutation(self):
        self.tool("uname", "echo Linux")
        for name in ("setup", "install-packages", "install-extras",
                     "install-herdr-plugins"):
            with self.subTest(name=name):
                result = self.run_script(name)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("macOS only", result.stderr)
        self.assertFalse((self.root / "log").exists())

    def test_single_brewfile_no_upgrade(self):
        result = self.run_script("install-packages")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.root / "log").read_text(),
                         "brew bundle --no-upgrade --file=Brewfile\n")

    def test_old_profiles_rejected(self):
        result = self.run_script("install-packages", "base", "minibook")
        self.assertEqual(result.returncode, 2)
        self.assertFalse((self.root / "log").exists())

    def test_herdr_plugins_are_installed_explicitly(self):
        result = self.run_script("install-herdr-plugins")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            (self.root / "log").read_text(),
            "herdr plugin install paulbkim-dev/vim-herdr-navigation --yes\n",
        )

    def test_setup_initializes_without_applying(self):
        result = self.run_script("setup")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.root / "log").read_text(),
                         f"chezmoi init --source {ROOT}\n")


@unittest.skipUnless(shutil.which("chezmoi"), "chezmoi required for template checks")
class PlatformTemplateTests(unittest.TestCase):
    def render(self, name, os_name):
        # Override the template context explicitly; do not initialize/apply live config.
        template = '{{ $ctx := dict "chezmoi" (dict "os" "' + os_name + '" "workingTree" "/example") }}{{ with $ctx }}'
        template += (ROOT / "home" / name).read_text() + '{{ end }}'
        return subprocess.run(["chezmoi", "--no-tty", "--dry-run",
                               "--refresh-externals=never", "execute-template", template],
                              capture_output=True, text=True, timeout=30)

    def test_macos_templates(self):
        config = self.render(".chezmoi.toml.tmpl", "darwin")
        self.assertEqual(config.returncode, 0, config.stderr)
        self.assertEqual(config.stdout.strip(), 'sourceDir = "/example"')
        ignore = self.render(".chezmoiignore", "darwin")
        self.assertEqual(ignore.returncode, 0, ignore.stderr)
        self.assertEqual(ignore.stdout.strip(), "")

    def test_templates_reject_other_hosts(self):
        for name in (".chezmoi.toml.tmpl", ".chezmoiignore"):
            with self.subTest(name=name):
                result = self.render(name, "linux")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("macOS only", result.stderr)


if __name__ == "__main__":
    unittest.main()
