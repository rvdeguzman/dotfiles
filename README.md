# Dotfiles

Curated macOS and Linux configuration, managed with
[chezmoi](https://www.chezmoi.io). This repository is the source of truth;
`~/.config` stays a normal application-state directory.

## Setup

```sh
./setup
```

`setup` installs chezmoi if missing (via Homebrew, pacman, or the official
installer), then runs `chezmoi init --apply` against this checkout. On first
run, `chezmoi init` asks a few questions and writes the answers to
`~/.config/chezmoi/chezmoi.toml`:

- **macOS** — which Homebrew package profiles to install (default: `core`)
- **Linux** — whether to manage Hyprland configs (default: on when Hyprland is
  running), whether to include the minibook Hyprland variant, and which Arch
  package profiles to install (default: `base`, plus `hyprland`/`i3` when the
  matching session is detected)

chezmoi runs in **symlink mode**: files in `$HOME` are symlinks into this
repository, so editing a config in place edits the checkout directly — commit
with plain git. Platform gating is handled by `home/.chezmoiignore`: Aerospace,
cmux, Karabiner, and OmniWM apply only on macOS; Hyprland, the minibook
variant, Mako, Waybar, and Wofi only on Linux.

Day-to-day commands (all take `--dry-run`/`-n`):

```sh
chezmoi diff            # preview what apply would change
chezmoi apply           # link configs + run package scripts
chezmoi add ~/.config/foo/bar.toml   # start managing a new file
chezmoi managed         # list everything managed
```

To change your answers later (e.g. enable more package profiles), edit
`~/.config/chezmoi/chezmoi.toml` and run `chezmoi apply`, or re-run
`chezmoi init` to be prompted again.

### Manual steps

The herdr keybinds in `home/dot_config/herdr` depend on a herdr-managed plugin
(`setup` does not install it):

```sh
herdr plugin install paulbkim-dev/vim-herdr-navigation --yes
```

## Package profiles

Package profiles are plain data files:

- macOS: `packages/macos/*.Brewfile`
- Arch Linux: `packages/arch/*.txt`

The `run_onchange` scripts under `home/.chezmoiscripts/` install the profiles
selected at `chezmoi init` and re-run automatically whenever a selected
profile file changes. On macOS this requires Homebrew and runs `brew bundle`
with `--no-upgrade`; on Arch it requires `paru` or `yay` and skips packages
that are already installed. Nothing is ever removed or upgraded.

## Shell rc files and secrets

`~/.zshrc`, `~/.zshenv`, and `~/.zprofile` are intentionally **not managed and
not tracked**: they accumulate machine-local keys, certs, and tool hooks, and
must never be replaced by an apply. They are plain local files; edit them
freely. Machine-only aliases and experiments can also go in `~/.zshrc.local`;
`*.local` files are ignored.

Other secrets never belong in this repository either. Shell configuration
optionally loads:

```text
~/.config/zsh/secrets.zsh
```

Start from the linked `~/.config/zsh/secrets.zsh.example`, fill the private
file locally, and restrict it:

```sh
chmod 600 ~/.config/zsh/secrets.zsh
```

## Layout

`home/` is the chezmoi source directory (selected by `.chezmoiroot`) and uses
chezmoi's naming: `dot_` becomes a leading dot, `empty_` marks intentionally
empty files:

```text
home/dot_config/tmux/tmux.conf   -> ~/.config/tmux/tmux.conf
home/dot_config/ghostty/config   -> ~/.config/ghostty/config
```

Generated logs, sessions, caches, databases, backups, authentication files,
and nested Git metadata remain outside the repository.
