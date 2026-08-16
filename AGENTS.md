# Agent instructions

This repository manages the user's dotfiles with chezmoi in copy mode. Read
`README.md` before assisting with setup or installation.

## Installation workflow

1. Inspect the OS, hardware, existing configs, and `git status`; preserve all
   user changes. Never discard or overwrite files without explicit approval.
2. Run `./setup` to install/initialize chezmoi. It intentionally does not apply
   anything.
3. Bootstrap the recommended wrapper with:
   `chezmoi apply ~/.local/bin/dot`
4. Run `chezmoi diff` (or `dot diff`) and summarize every affected area. Do not
   run a full apply until the user approves the reviewed diff.
5. Before applying, inspect every external target from
   `home/.chezmoiexternal.toml`. A target is valid only when it is a Git
   checkout with the expected `origin`; a bare local commit or unrelated repo
   does not qualify. If a target conflicts, first make a timestamped `cp -a`
   backup with user approval and restrict backup permissions to the user. Then
   replace/repair the checkout and preserve only required ignored machine
   state. Never silently delete a target, push an ad-hoc local repository, or
   connect a repository that tracks auth data, sessions, or caches to a remote.
6. Apply with `dot apply`. Use a targeted `chezmoi apply <path>` when only one
   file should be installed.
7. Verify `chezmoi status` afterward and report failures or remaining drift.

## Packages

- Package installation is always explicit; chezmoi does not install packages.
- On Arch, inspect `packages/arch/*.txt` and run `./install-packages base` plus
  only the machine profiles that actually apply. Do not install `minibook` on
  other hardware.
- Package installation may require the user to enter a sudo password or answer
  conflict prompts. Never request, capture, or store their password.
- Do not remove or replace a conflicting package without explaining the choice
  and receiving approval.

## Omarchy machines

- After apply on an Omarchy (Arch + Hyprland) machine, follow
  `docs/omarchy.md`: activate the `vague-black` theme and set the per-machine
  defaults (ghostty terminal, brave browser). Those defaults are machine-local
  state, not chezmoi-managed, so they must be re-run on each new machine.

## Doom Emacs

- The `~/.config/doom` external is only the user's Doom configuration; cloning
  it does not install the Doom Emacs core or its packages.
- After chezmoi has cloned `~/.config/doom`, install Doom with the current
  upstream commands:
  `git clone --depth 1 https://github.com/doomemacs/core ~/.config/emacs`
  followed by `~/.config/emacs/bin/doom install`.
- Do not clone over an existing Emacs directory. Inspect and back up
  `~/.config/emacs` or `~/.emacs.d` first. Run `doom sync` after subsequent
  module or package configuration changes.

## Safety and local state

- `~/.zshrc`, `~/.zshenv`, and `~/.zprofile` are intentionally unmanaged. To
  install the example zsh config, back up the existing file and explicitly copy
  `home/dot_config/zsh/zshrc.example`; verify Oh My Zsh exists first.
- Never add secrets. Keep `~/.config/zsh/secrets.zsh` local with mode `600`.
- External repositories (`nvim`, `doom`, and `pi-config`) are normal Git
  checkouts. Preserve their local changes; a pull may fail when they are dirty.
- Edit chezmoi templates in this repository, not only their rendered files in
  `$HOME`. `dot sync` re-adds managed non-template files but skips templates.
- Do not modify Omarchy source under `~/.local/share/omarchy/`.
- After applied Hyprland changes, run `hyprctl reload` and
  `hyprctl configerrors`. After Waybar changes, restart Waybar with the Omarchy
  command appropriate for the installed version.
