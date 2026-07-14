# Dotfiles

Curated macOS and Linux configuration. This repository is the source of truth;
`~/.config` stays a normal application-state directory.

## Setup

```sh
./setup
```

The interactive selector detects macOS or Arch Linux, preselects conservative
configuration and package defaults, then opens a keyboard-driven checklist:

- `j` / `k` moves the cursor down or up
- Space toggles the highlighted item
- `a` selects all; `n` selects none
- Enter accepts the current list; `q` exits without changes

The selector and `./setup list` hide incompatible entries instead of showing
one combined list. Aerospace, cmux, Karabiner, and OmniWM are macOS-only;
Hyprland, the minibook profile, Mako, Waybar, and Wofi are Linux-only. All
other components are shared. Package profiles are already separated under
`packages/macos/` and `packages/arch/`, so only profiles supported by the
current operating system appear. An explicitly named component remains
available for advanced cross-platform use, such as `./setup link hypr`.

The final review defaults to **preview only**. Applying changes requires
choosing `apply` and confirming a second time. Passing `--dry-run` locks the
session to preview mode:

```sh
./setup --dry-run
```

The command-line interface remains available:

```sh
./setup list
./setup --dry-run terminal ghostty
./setup terminal
./setup --dry-run link shell tmux nvim
./setup link shell tmux nvim
./setup --dry-run packages core dev
./setup packages core dev
```

`./setup terminal` asks for one terminal emulator with `j` / `k` and
Space or Enter. Pass `ghostty`, `kitty`, or `alacritty` to skip the prompt.

`link` discovers components under `configs/` and creates absolute, leaf-file
symlinks at their home-relative paths. Existing files are preserved under:

```text
~/.local/state/dotfiles/backups/<timestamp-pid>/
```

Re-running the same command is safe: correct links are skipped.

### Manual steps

The herdr keybinds in `configs/herdr` depend on a herdr-managed plugin
(`setup` does not install it):

```sh
herdr plugin install paulbkim-dev/vim-herdr-navigation --yes
```

## Package profiles

Package profiles are plain data files:

- macOS: `packages/macos/*.Brewfile`
- Arch Linux: `packages/arch/*.txt`

On macOS, `setup packages` requires Homebrew and runs `brew bundle` with
`--no-upgrade`. On Arch, it requires `paru` or `yay`. The setup script never
installs a package manager, removes packages, or upgrades existing packages.

## Secrets

Secrets never belong in this repository. Shell configuration optionally loads:

```text
~/.config/zsh/secrets.zsh
```

Start from the linked `~/.config/zsh/secrets.zsh.example`, fill the private
file locally, and restrict it:

```sh
chmod 600 ~/.config/zsh/secrets.zsh
```

Machine-only aliases and experiments can go in `~/.zshrc.local`; `*.local`
files are ignored.

## Layout

Each directory in `configs/` is independently selectable and mirrors paths
relative to `$HOME`:

```text
configs/tmux/.config/tmux/tmux.conf -> ~/.config/tmux/tmux.conf
configs/shell/.zshrc                -> ~/.zshrc
```

Generated logs, sessions, caches, databases, backups, authentication files,
and nested Git metadata remain outside the repository.
