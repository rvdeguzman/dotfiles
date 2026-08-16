# Dotfiles

macOS and Linux configuration, managed with [chezmoi](https://www.chezmoi.io)
in **copy mode**: files in `$HOME` are real files, not symlinks. Nothing moves
in either direction without an explicit command — editing a live config does
not touch this repo, and this repo never touches the machine outside of an
apply you confirmed.

## Setup

```sh
./setup          # installs chezmoi if missing, runs chezmoi init (no apply)
chezmoi diff     # review what apply would do
chezmoi apply    # materialize configs, clone the vendored repos
```

On Linux, `chezmoi init` asks whether to manage Hyprland configs and whether
to use the MiniBook X variant; macOS asks nothing. Re-run `chezmoi init` to
answer again, or edit `~/.config/chezmoi/chezmoi.toml`.

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
