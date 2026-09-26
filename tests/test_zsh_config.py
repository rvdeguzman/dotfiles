"""Exercise the opt-in zsh example without loading real configs or history."""
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
EXAMPLE = ROOT / "home/dot_config/zsh/zshrc.example"
OMZ_NVM = Path.home() / ".oh-my-zsh/plugins/nvm/nvm.plugin.zsh"


@unittest.skipUnless(shutil.which("zsh"), "zsh required")
class ZshConfigTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name)
        self.file(".oh-my-zsh/oh-my-zsh.sh", "# Test stub: no real plugins.\n")
        self.env = {
            "HOME": str(self.home), "PATH": "/usr/bin:/bin",
            "TERM": "xterm-256color", "ZDOTDIR": str(self.home),
        }

    def file(self, name, content, executable=False):
        path = self.home / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        if executable:
            path.chmod(0o700)
        return path

    def run_config(self, checks):
        result = subprocess.run(
            [shutil.which("zsh"), "-dfic", 'source "$1"; ' + checks,
             "test", str(EXAMPLE)], env=self.env, capture_output=True,
            text=True, timeout=15,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        return result.stdout

    def test_optional_integrations_can_be_absent(self):
        output = self.run_config("bindkey '^[[A'; print -r -- $EDITOR $VISUAL")
        self.assertNotIn("clio-history", output)
        self.assertIn("nvim nvim", output)

    def test_local_secrets_are_loaded(self):
        self.file(".config/zsh/secrets.zsh", "export TEST_LOCAL_SECRET=fixture\n")
        self.run_config('[[ "$TEST_LOCAL_SECRET" == fixture ]]')

    def test_clio_binds_both_up_sequences_and_ctrl_r(self):
        self.env["XDG_DATA_HOME"] = str(self.home / "custom-data")
        self.file(".cargo/bin/clio", "#!/bin/sh\nexit 0\n", executable=True)
        self.file("custom-data/clio/clio.zsh", """
_test_clio() { :; }
zle -N clio-history _test_clio
bindkey '^R' clio-history
""")
        output = self.run_config("bindkey '^[[A'; bindkey '^[OA'; bindkey '^R'")
        self.assertEqual(output.count("clio-history"), 3)

    def test_clio_without_hook_preserves_up(self):
        self.file(".cargo/bin/clio", "#!/bin/sh\nexit 0\n", executable=True)
        self.assertNotIn("clio-history", self.run_config("bindkey '^[[A'"))

    def test_nvm_lazy_settings_precede_omz_and_no_eager_source_remains(self):
        self.env["NVM_DIR"] = str(self.home / "custom-nvm")
        self.file("custom-nvm/nvm.sh", "NVM_EAGER_LOAD=yes\n")
        self.file("custom-nvm/bash_completion", "NVM_EAGER_LOAD=yes\n")
        self.file(".oh-my-zsh/oh-my-zsh.sh", """
zstyle -t ':omz:plugins:nvm' lazy && OMZ_SAW_LAZY=yes
[[ ${plugins[(Ie)nvm]} -gt 0 ]] && OMZ_SAW_NVM=yes
[[ "$NVM_DIR" == "$HOME/custom-nvm" ]] && OMZ_SAW_DIR=yes
""")
        self.run_config("""
[[ "$OMZ_SAW_LAZY" == yes && "$OMZ_SAW_NVM" == yes && "$OMZ_SAW_DIR" == yes ]] || exit 1
[[ -z "$NVM_EAGER_LOAD" ]]
""")

    def use_installed_omz_plugin(self):
        # Load only the plugin code, never real home configs, NVM, or history.
        if not OMZ_NVM.is_file():
            self.skipTest("installed Oh My Zsh NVM plugin required for integration check")
        self.file(".oh-my-zsh/plugins/nvm/nvm.plugin.zsh", OMZ_NVM.read_text())
        self.file(".oh-my-zsh/oh-my-zsh.sh",
                  'source "$ZSH/plugins/nvm/nvm.plugin.zsh"\n')

    def test_real_omz_plugin_without_nvm_is_harmless(self):
        self.use_installed_omz_plugin()
        self.run_config('(( ! $+functions[nvm] && ! $+functions[node] ))')

    def test_real_omz_plugin_loads_once_on_first_command(self):
        self.use_installed_omz_plugin()
        self.env["NVM_DIR"] = str(self.home / "custom-nvm")
        self.file(".local/bin/node", "#!/bin/sh\necho old-node\n", executable=True)
        for command in ("node", "npm", "npx"):
            self.file(f"custom-nvm/versions/node/test/bin/{command}",
                      f'#!/bin/sh\nprintf "%s\\n" "nvm-{command} $*"\n', executable=True)
        self.file("custom-nvm/nvm.sh", """
(( NVM_LOAD_COUNT += 1 ))
export NVM_BIN="$NVM_DIR/versions/node/test/bin"
path=("$NVM_BIN" $path)
nvm() { print -r -- "nvm $*"; }
""")
        self.file("custom-nvm/bash_completion", "NVM_COMPLETION_LOADED=yes\n")
        for trigger in ("nvm", "node", "npm", "npx"):
            with self.subTest(trigger=trigger):
                output = self.run_config("""
[[ -z "$NVM_LOAD_COUNT" && -z "$NVM_COMPLETION_LOADED" ]] || exit 1
(( $+functions[node] && $+functions[nvm] )) || exit 1
""" + trigger + " --version\n" + """
[[ "$NVM_LOAD_COUNT" == 1 && "$NVM_COMPLETION_LOADED" == yes ]] || exit 1
[[ "$path[1]" == "$NVM_BIN" ]] || exit 1
[[ ${(j.:.)path} != *"$NVM_BIN"*"$NVM_BIN"* ]] || exit 1
(( ! $+functions[node] )) || exit 1
node --version
[[ "$NVM_LOAD_COUNT" == 1 ]]
""")
                self.assertIn("nvm-node --version", output)
                self.assertNotIn("old-node", output)


if __name__ == "__main__":
    unittest.main()
