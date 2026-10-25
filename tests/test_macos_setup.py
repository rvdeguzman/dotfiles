"""Installer platform guards and macOS command routing, without real installs."""
import os
from pathlib import Path
import re
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
        for name in ("brew", "npm", "curl", "herdr", "defaults"):
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
        for name in ("dot", "install-externals", "install-packages", "install-extras",
                     "install-herdr-plugins", "install-nvm", "configure-rex"):
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

    def test_emacs_formula_and_build_options(self):
        brewfile = (ROOT / "Brewfile").read_text()
        entries = re.findall(r'^brew "([^"]*emacs[^"]*)"(.*)$',
                             brewfile, re.MULTILINE)
        self.assertEqual(len(entries), 1)
        formula, options = entries[0]
        self.assertEqual(formula, "railwaycat/emacsmacport/emacs-mac@31exp")
        self.assertEqual(set(re.findall(r'"([^"]+)"', options)), {
            "with-native-compilation", "with-librsvg",
            "with-xwidgets", "with-starter",
        })
        self.assertNotIn("head:", options)

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

    def test_rex_hide_moves_off_cmd_h(self):
        result = self.run_script("configure-rex")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            (self.root / "log").read_text(),
            "defaults write com.superlogical.rex NSUserKeyEquivalents -dict "
            "Hide Rex Beta @~^$h Hide Rex @~^$h\n",
        )

    def test_nvm_reuses_existing_install_and_selects_node_24(self):
        nvm_dir = self.root / "nvm"
        nvm_dir.mkdir()
        (nvm_dir / "nvm.sh").write_text(
            'nvm() { printf "nvm %s\\n" "$*" >> "$LOG"; }\n'
        )
        self.env["NVM_DIR"] = str(nvm_dir)
        result = self.run_script("install-nvm")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.root / "log").read_text(),
                         "nvm install 24\nnvm alias default 24\n")

    def test_nvm_refuses_conflicting_directory(self):
        nvm_dir = self.root / "nvm"
        nvm_dir.mkdir()
        self.env["NVM_DIR"] = str(nvm_dir)
        result = self.run_script("install-nvm")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("inspect it before installing", result.stderr)
        self.assertFalse((self.root / "log").exists())

    def test_nvm_fresh_install_uses_pinned_upstream(self):
        nvm_dir = self.root / "nvm"
        self.env["NVM_DIR"] = str(nvm_dir)
        self.tool("git", '''
printf 'git %s\\n' "$*" >> "$LOG"
mkdir -p "$NVM_DIR"
printf '%s\\n' 'nvm() { printf "nvm %s\\n" "$*" >> "$LOG"; }' > "$NVM_DIR/nvm.sh"
''')
        result = self.run_script("install-nvm")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.root / "log").read_text(),
                         "git clone --depth 1 --branch v0.40.8 "
                         f"https://github.com/nvm-sh/nvm.git {nvm_dir}\n"
                         "nvm install 24\nnvm alias default 24\n")

    def test_install_externals_clones_only_missing_paths(self):
        home = self.root / "home"
        (home / ".config/nvim").mkdir(parents=True)
        self.env["HOME"] = str(home)
        self.tool("git", 'printf "git %s\\n" "$*" >> "$LOG"')
        result = self.run_script("install-externals")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("exists: ~/.config/nvim", result.stdout)
        self.assertEqual((self.root / "log").read_text(),
                         f"git clone https://github.com/rvdeguzman/doom.git {home}/.config/doom\n"
                         f"git clone https://github.com/rvdeguzman/pi-config.git {home}/.pi/agent\n")


class DotTests(unittest.TestCase):
    """Run ./dot from a throwaway repo copy so the real home/ and $HOME are never touched."""

    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.repo = Path(tmp.name) / "repo"
        self.home = Path(tmp.name) / "home"
        (self.repo / "home/.config/app").mkdir(parents=True)
        self.home.mkdir()
        shutil.copy2(ROOT / "dot", self.repo / "dot")
        subprocess.run(["git", "init", "-q", str(self.repo)], check=True)
        self.env = dict(os.environ, HOME=str(self.home), XDG_STATE_HOME=str(self.home / "state"))

    def write(self, base, rel, text):
        path = base / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        return path

    def dot(self, *args):
        result = subprocess.run([str(self.repo / "dot"), *args], capture_output=True,
                                text=True, env=self.env, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout

    def test_apply_installs_and_backs_up_overwritten_file(self):
        self.write(self.repo / "home", ".config/app/new.conf", "new\n")
        self.write(self.repo / "home", ".config/app/edit.conf", "repo\n")
        self.write(self.home, ".config/app/edit.conf", "live\n")
        unmanaged = self.write(self.home, ".config/app/local.conf", "mine\n")
        self.assertEqual(self.dot("status"), "M .config/app/edit.conf\nA .config/app/new.conf\n")
        self.dot("apply")
        self.assertEqual((self.home / ".config/app/new.conf").read_text(), "new\n")
        self.assertEqual((self.home / ".config/app/edit.conf").read_text(), "repo\n")
        self.assertEqual(unmanaged.read_text(), "mine\n")
        backups = list((self.home / "state/dotfiles/backups").glob("*/.config/app/edit.conf"))
        self.assertEqual([b.read_text() for b in backups], ["live\n"])
        self.assertEqual(self.dot("status"), "")

    def test_sync_copies_live_edits_back_without_adding_new_files(self):
        repo_file = self.write(self.repo / "home", ".config/app/edit.conf", "repo\n")
        self.write(self.home, ".config/app/edit.conf", "live\n")
        self.write(self.home, ".config/app/secret.conf", "token\n")
        self.dot("sync")
        self.assertEqual(repo_file.read_text(), "live\n")
        self.assertFalse((self.repo / "home/.config/app/secret.conf").exists())


if __name__ == "__main__":
    unittest.main()
