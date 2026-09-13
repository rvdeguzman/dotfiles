# Dotfiles

macOS-only configuration, managed with [chezmoi](https://www.chezmoi.io)
in **copy mode**: files in `$HOME` are real files, not symlinks. Nothing moves
in either direction without an explicit command — editing a live config does
not touch this repo, and this repo never touches the machine outside of an
apply you confirmed.

## Setup

Start with [the machine setup runbook](docs/machine-setup.md), including
prerequisite inspection, approval checkpoints, backups, and functional checks.

```sh
make doctor                     # read-only local preflight (requires Python 3)
./setup                         # installs chezmoi if missing; init, no apply
chezmoi apply ~/.local/bin/dot   # bootstrap wrapper after inspecting the target
dot diff                        # review every affected area and external target
dot apply                       # only after approval; asks again before applying
chezmoi status                  # report remaining drift
```

Doctor never installs, fetches, or applies. Failures return a nonzero status;
warnings and skipped checks still need review. Python 3.11+ enables external
manifest checks. See the runbook for fresh machines without Python/developer tools.

Homebrew is required. Setup has no machine-profile prompts; setup, installers,
and chezmoi templates reject non-macOS hosts. Previous Linux configuration is
available in Git history, not managed by the current tree. Existing local files
are not deleted by this repository cutover.

### Emacs and Doom

Follow [the Emacs/Doom installation guide](docs/doom-emacs.md): install Emacs
first, apply the personal configuration after reviewing the diff, then install
Doom core and its packages separately. The macOS Brewfile selects Railwaycat's
stable Emacs 29, Doom's preferred macOS port, with modules enabled by default.
The guide covers prerequisites, safe GUI app registration, existing-install
checks, and `doom install` / `doom sync` / `doom doctor` verification.

The Doom external provides only `~/.config/doom`; it does **not** install
Emacs or Doom core (`~/.config/emacs`).

## Daily workflow

The `dot` wrapper (installed to `~/.local/bin/dot`) keeps everything
diff-first:

```sh
dot apply        # chezmoi diff, ask y/N, then apply
dot sync         # chezmoi re-add: pull edits to *managed* files back into
                 # the repo, then show git status — commit with plain git
dot add ~/.config/foo/bar.toml   # start managing a new file (explicit only)
dot diff / dot status / ...      # any other chezmoi command passes through
```

`re-add` only updates files that are already managed. New files — including
anything secret — never enter the repo unless you `dot add` them.

## Vendored repos

The heavy-churn configs are their own repositories, declared in
`home/.chezmoiexternal.toml` and cloned/pulled by `chezmoi apply`
(at most once per hour; force with `chezmoi apply -R`):

| checkout            | repo                    |
|---------------------|-------------------------|
| `~/.config/nvim`    | rvdeguzman/nvim         |
| `~/.config/doom`    | rvdeguzman/doom         |
| `~/.pi/agent`       | rvdeguzman/pi-config    |

Each is a normal git checkout: edit in place, commit and push there.
Everything pi-related lives in pi-config, checked out directly at
`~/.pi/agent`: skills, extensions, agents, tools, `update-skills`, and the
config files (`AGENTS.md`, `settings.json`, `models.json`,
`web-search.json`). Its whitelist `.gitignore` keeps the machine state
living in the same directory (auth, sessions, caches) untracked.

## Packages

The root `Brewfile` is the single package list, installed **only** by hand:

```sh
./install-packages   # brew bundle --no-upgrade --file=Brewfile
```

There are no package profiles. This installer never removes or upgrades
existing packages, and nothing installs during apply.

Python projects use `uv` for virtual environments and dependencies; it is
included in the Brewfile.

Tools outside Homebrew (`pi`, `herdr`, Oh My Zsh) are installed explicitly by
`./install-extras`.

Herdr plugins required by the managed configuration are declared separately and
installed explicitly after Herdr itself:

```sh
make herdr-plugins
```

This runs `./install-herdr-plugins`; it currently installs the Vim/Herdr pane
navigation plugin and never runs during setup or chezmoi apply.

### Clio shell history

[Clio](https://github.com/rvdeguzman/clio) is the personal, local-only Atuin
replacement for zsh. It remains a separate manually managed checkout, not a
chezmoi external. See [installation and migration instructions](docs/clio.md)
for `make install`, optional history import **before** enabling the hook, and
explicit `~/.zshrc` integration. Shell history stays private and unmanaged.

### macOS developer tools

Maintain Apple's Command Line Tools explicitly (never during setup/apply):

```sh
make xcode-install   # first-time Apple installer, only if tools are missing
make xcode-check     # show selected tools/SDK and available CLT update labels
make xcode-update LABEL="<exact Command Line Tools label from xcode-check>"
```

The update target rescans, validates the exact CLT label, asks for confirmation,
then invokes `sudo softwareupdate` in your terminal. Enter any password there,
not in chat. It does not install unrelated macOS updates, restart the machine,
remove developer tools, or change `xcode-select`. Full Xcode is updated separately
through the App Store or Apple Developer downloads. If no CLT label is offered
but the SDK is broken, check System Settings → General → Software Update and
Apple's developer downloads; this helper does not force hidden updates.

Keep Command Line Tools current after macOS upgrades, especially for Emacs native
compilation. See [Doom troubleshooting](docs/doom-emacs.md).

## Secrets

`~/.zshrc`, `~/.zshenv`, and `~/.zprofile` are intentionally unmanaged local
files. Secrets go in `~/.config/zsh/secrets.zsh` (start from the managed
`secrets.zsh.example`, then `chmod 600`). `*.local` files are gitignored.
Copy mode means a secret pasted into a live config still stays out of the
repo until an explicit `dot add`/`dot sync` — review before committing.

## Layout

`home/` is the chezmoi source directory (`.chezmoiroot`), using chezmoi
naming: `dot_` = leading dot, `private_` = restricted permissions,
`executable_` = +x, `.tmpl` = template.

- `home/.chezmoiignore` guards against use on non-macOS hosts; there are no
  per-platform config branches.
- `home/dot_config/` contains Aerospace, Ghostty, tmux, zsh examples, and other
  application settings. Aerospace uses native commands without helper scripts.
- `home/dot_config/wallpapers/` keeps the wallpaper collection, installed at
  `~/.config/wallpapers`. Selecting a macOS desktop background is manual.
- `Brewfile` declares packages; `docs/` documents explicit installation and
  verification. Edit any chezmoi templates in the source, not rendered files.

**Syncing machines:** commit and push with plain git; on the other machine
`git pull && dot apply`.
