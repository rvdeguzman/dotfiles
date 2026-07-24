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
with plain git. Some directories are additionally linked *wholesale* (see
[Layout](#layout)), so files added to them show up in `git status`
immediately, with no `chezmoi add` required. Platform gating is handled by `home/.chezmoiignore`: Aerospace,
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

The herdr keybinds in `herdr/` depend on a herdr-managed plugin
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

Two patterns are used, chosen by who writes to a directory:

| who writes there        | pattern                     | examples |
|-------------------------|-----------------------------|----------|
| only me                 | **whole-directory symlink** | `nvim/`, `doom/`, `herdr/`, `pi/{skills,extensions,agents}` |
| mostly the app (state, secrets) | **per-file management** | `~/.omp`, `~/.pi`, everything under `home/` |

**Whole-directory symlinks.** The real content lives at the repository root
(`nvim/`, `doom/`, `herdr/`, `pi/`); a `symlink_*.tmpl` entry under `home/`
makes the live path (e.g. `~/.config/nvim`) a symlink to it. New files you
create there appear as untracked in `git status` right away — just `git add`
them. Runtime junk the app writes into those directories (logs, sockets,
plugin installs, doom's `.local`) is excluded by a `.gitignore` inside each
directory. Never `git add -f` around those ignores: some entries
(`doom/secrets.el`, `doom/leetcode.el`) guard secrets.

**Per-file management.** `home/` is the chezmoi source directory (selected by
`.chezmoiroot`) and uses chezmoi's naming: `dot_` becomes a leading dot,
`private_` restricts permissions, `empty_` marks intentionally empty files:

```text
home/dot_config/tmux/tmux.conf            -> ~/.config/tmux/tmux.conf
home/private_dot_pi/private_agent/settings.json -> ~/.pi/agent/settings.json
```

State-heavy homes like `~/.pi` and `~/.omp` stay real directories so their
sessions, caches, and auth tokens never enter the worktree; only the config
files inside them are managed. Adding a new config there is
`chezmoi add <path>` + `chezmoi apply`; `chezmoi unmanaged ~/.pi` lists what
isn't managed yet. `~/.pi/agent/{skills,extensions,agents}` are the exception:
they are whole-directory symlinks into `pi/`, since that is where new skills
and extensions get added. The pointer skills inside `pi/skills/` link to
`~/.agents/skills`, which must be cloned separately.

**Syncing.** Commit and push with plain git. On another machine,
`git pull && chezmoi apply` — pulled content is live immediately (configs
resolve into the worktree); `chezmoi apply` only materializes structural
changes (new symlink entries, ignore rules, package scripts). Note the
corollary: whatever state this worktree is in — including a checked-out
branch — *is* the live configuration.

Generated logs, sessions, caches, databases, backups, authentication files,
and nested Git metadata remain outside the repository.
