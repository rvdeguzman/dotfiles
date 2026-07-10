# Dotfiles

Curated macOS and Linux configuration. This repository is the source of truth;
`~/.config` stays a normal application-state directory.

## Setup

```sh
./setup list
./setup --dry-run link shell tmux nvim
./setup link shell tmux nvim
./setup packages core dev
```

Run `./setup` without arguments for interactive selection.

`link` discovers components under `configs/` and creates absolute, leaf-file
symlinks at their home-relative paths. Existing files are preserved under:

```text
~/.local/state/dotfiles/backups/<timestamp-pid>/
```

Re-running the same command is safe: correct links are skipped. Use
`--dry-run` before a large selection to preview every move and link.

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
