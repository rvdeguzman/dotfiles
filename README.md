# Dotfiles

macOS and Linux configuration, managed with [chezmoi](https://www.chezmoi.io)
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

On Linux, `chezmoi init` asks whether to manage Hyprland configs and whether
to use the MiniBook X variant; macOS asks nothing. Re-run `chezmoi init` to
answer again, or edit `~/.config/chezmoi/chezmoi.toml`.

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

Package lists are plain data, installed **only** by hand:

```sh
./install-packages                    # macOS: brew bundle --no-upgrade, packages/macos/Brewfile
./install-packages base minibook      # Arch: Omarchy extras via paru/yay -S --needed
```

macOS is a single `packages/macos/Brewfile`; Arch assumes Omarchy and lists
only cross-platform tools, personal extras, and machine-specific packages in
`packages/arch/*.txt`. Omarchy owns the desktop and base system packages.
Nothing is ever removed or upgraded, and nothing installs during apply.

Python projects use `uv` for virtual environments and dependencies; it is
installed with the package profiles.

Tools that don't come from brew/pacman (`pi`, `herdr`) are installed by
`./install-extras`, macOS only for now.

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
compilation. See [Doom troubleshooting](docs/doom-emacs.md). Linux support remains
in place; migration to macOS-only is a separate change.

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

- Platform gating lives in `home/.chezmoiignore` (Aerospace on macOS;
  Hyprland/Waybar/wallpapers on Linux).
- The Hyprland desktop and MiniBook variants share `home/dot_config/hypr/`:
  variant-only files are ignore-gated, the three shared filenames
  (`hyprland.conf`, `hypridle.conf`, `hyprlock.conf`) are templates switching
  on the `minibook` flag. Template files are skipped by `re-add` — edit them
  in the repo (or `chezmoi edit`), not via sync.

**Syncing machines:** commit and push with plain git; on the other machine
`git pull && dot apply`.
