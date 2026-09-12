#!/usr/bin/env python3
"""Local-only preflight. No installs, fetches, applies, or history inspection."""
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys

try:
    import tomllib
except ImportError:
    tomllib = None

ROOT = Path(__file__).resolve().parents[1]


def run(*args):
    env = dict(os.environ, GIT_OPTIONAL_LOCKS="0", GIT_TERMINAL_PROMPT="0",
               HOMEBREW_NO_AUTO_UPDATE="1", HOMEBREW_NO_ANALYTICS="1")
    try:
        result = subprocess.run(args, capture_output=True, text=True, env=env,
                                timeout=30, stdin=subprocess.DEVNULL)
        return result.returncode, result.stdout.strip()
    except (OSError, subprocess.TimeoutExpired):
        return 1, ""


def canonical_remote(url):
    # Accept equivalent GitHub HTTPS/SSH origins, but not arbitrary hosts or credentials.
    match = re.fullmatch(r"(?:https://github\.com/|git@github\.com:|ssh://git@github\.com/)([\w.-]+/[\w.-]+?)(?:\.git)?/?", url)
    return match.group(1).lower() if match else None


class Doctor:
    def __init__(self, root=ROOT, home=None):
        self.root = root
        self.home = home or Path.home()
        self.warnings = 0
        self.errors = 0

    def report(self, level, message):
        print(f"[{level}] {message}")
        self.warnings += level == "WARN"
        self.errors += level == "FAIL"

    def command(self, name, required=True):
        path = shutil.which(name)
        self.report("OK" if path else ("FAIL" if required else "WARN"),
                    f"{name}: {path or 'not on PATH'}")
        return path

    def checkout(self, path, expected=None, required=True):
        label = str(path).replace(str(self.home) + "/", "~/", 1)
        if not path.exists():
            self.report("FAIL" if required else "WARN", f"{label}: missing checkout")
            return
        code, top = run("git", "-C", str(path), "rev-parse", "--show-toplevel")
        if code or Path(top).resolve() != path.resolve():
            self.report("FAIL", f"{label}: not a Git working-tree root; inspect before replacing")
            return
        if expected:
            code, origin = run("git", "-C", str(path), "remote", "get-url", "origin")
            if code or not canonical_remote(origin) or canonical_remote(origin) != canonical_remote(expected):
                self.report("FAIL", f"{label}: origin missing or unexpected (value suppressed)")
            else:
                self.report("OK", f"{label}: expected origin")
        code, status = run("git", "-C", str(path), "status", "--porcelain", "--untracked-files=normal")
        if code:
            self.report("FAIL", f"{label}: cannot inspect Git status")
        elif status:
            self.report("WARN", f"{label}: local changes present; preserve them (paths suppressed)")
        else:
            self.report("OK", f"{label}: clean working tree")

    def externals(self):
        if tomllib is None:
            self.report("WARN", "Python 3.11+ needed to inspect .chezmoiexternal.toml; check externals manually")
            return
        try:
            data = tomllib.loads((self.root / "home/.chezmoiexternal.toml").read_text())
        except (OSError, ValueError):
            self.report("FAIL", "Cannot parse external manifest")
            return
        for target, spec in data.items():
            if (not isinstance(spec, dict) or spec.get("type") != "git-repo"
                    or not isinstance(spec.get("url"), str)
                    or Path(target).is_absolute() or ".." in Path(target).parts):
                self.report("FAIL", "Unsupported external declaration; review manifest manually")
                continue
            self.checkout(self.home / target, spec["url"])

    def packages(self):
        # Current Brewfile is declarative; don't evaluate arbitrary Ruby or run bundle.
        try:
            text = (self.root / "Brewfile").read_text()
        except OSError:
            self.report("FAIL", "Cannot read macOS Brewfile")
            return
        for kind, flag in (("brew", "--formula"), ("cask", "--cask")):
            code, output = run("brew", "list", flag, "--full-name")
            if code:
                self.report("FAIL", f"Cannot list installed Homebrew {kind} packages")
                continue
            installed = {name.rsplit("/", 1)[-1] for name in output.splitlines()}
            wanted = re.findall(r'^' + kind + r'\s+"([^"]+)"', text, re.M)
            missing = [name for name in wanted if name.rsplit("/", 1)[-1] not in installed]
            if kind == "brew":
                # Names such as "python" resolve to versioned formulae. Ask Homebrew
                # about installed prefixes rather than falsely reporting the alias missing.
                missing = [name for name in missing
                           if run("brew", "--prefix", "--installed", name)[0]]
            if missing:
                self.report("WARN", f"Missing Brewfile {kind} packages: {', '.join(missing)}")
            else:
                self.report("OK", f"All declared {kind} packages installed (build options/versions not checked)")

    def macos(self):
        for args, label in ((('xcode-select', '-p'), 'Selected developer directory'),
                            (('xcrun', '--show-sdk-path'), 'Active SDK')):
            code, output = run(*args)
            self.report("FAIL" if code else "OK", f"{label}: {output if not code else 'unavailable; see make xcode-install/check'}")
        if self.command("brew"):
            self.packages()
        app = Path("/Applications/Emacs.app")
        self.report("OK" if app.is_dir() else "WARN", "Emacs GUI app registered" if app.is_dir() else
                    "Emacs GUI app absent/broken; see docs/doom-emacs.md")

    def drift(self):
        if not self.command("chezmoi"):
            return
        # Verify the active source first: do not accidentally audit a different checkout.
        code, source = run("chezmoi", "--no-tty", "source-path")
        if code or Path(source).resolve() != (self.root / "home").resolve():
            self.report("WARN", "chezmoi not initialized to this repo's home/; run ./setup after review")
            return
        code, status = run("chezmoi", "--no-tty", "--dry-run", "--refresh-externals=never",
                           "--skip-secrets", "status", "--exclude=externals")
        if code:
            self.report("WARN", "chezmoi status failed; inspect locally (error output suppressed)")
        elif status:
            self.report("WARN", f"chezmoi reports {len(status.splitlines())} status entries; review dot diff before apply")
        else:
            self.report("OK", "No managed-file drift detected (externals and secret templates excluded)")

    def check(self):
        print(f"Machine: {platform.system()} {platform.release()} / {platform.machine()}")
        print("Local checks only; no update scans, builds, applies, or history reads.")
        if platform.system() != "Darwin":
            self.report("FAIL", "This repository supports macOS only; no further checks performed")
            return 1
        git = self.command("git")
        for tool in ("zsh", "rg", "fd", "emacs"):
            self.command(tool)
        for tool in ("dot", "cargo", "clio"):
            self.command(tool, required=False)
        self.macos()
        if git:
            self.checkout(self.root)
            self.externals()
            self.checkout(self.home / ".config/emacs", "https://github.com/doomemacs/core")
        if (self.home / ".emacs.d").exists() or (self.home / ".emacs.d").is_symlink():
            self.report("WARN", "~/.emacs.d exists; inspect for conflicts before installing Doom")
        if not (self.home / ".oh-my-zsh/oh-my-zsh.sh").is_file():
            self.report("WARN", "Oh My Zsh not found at default path; verify before copying zshrc.example")
        self.drift()
        print(f"\nSummary: {self.errors} failures, {self.warnings} warnings.")
        print("Manual follow-up: docs/machine-setup.md (GUI, native compilation, fonts, shell bindings).")
        return 1 if self.errors else 0


if __name__ == "__main__":
    sys.exit(Doctor().check())
