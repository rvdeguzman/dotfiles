# Agent instructions

This repository manages the user's dotfiles with chezmoi in copy mode. Read
`README.md` before assisting with setup or installation.

## Installation workflow

Follow `docs/machine-setup.md` for the complete sequence and approval checkpoints.
Start and finish with `make doctor` (local-only, read-only; Python 3 required,
3.11+ for external manifest checks). Review warnings and skipped checks even
when it exits zero. It does not replace reviewed diffs or functional checks.

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

## macOS developer tools

- Use `make xcode-check` to inspect Command Line Tools updates and
  `make xcode-update LABEL="<exact offered CLT label>"` for an explicitly
  approved update. `make xcode-install` opens the first-time Apple installer.
- Never use `softwareupdate --all` for a CLT-only request, delete the existing
  tools, or switch the developer directory without explicit approval.
- Let the user enter any sudo password directly in their terminal. Full Xcode
  updates are separate from CLT maintenance. Linux support remains until an
  explicit macOS-only migration is requested.

## Doom Emacs

- Follow `docs/doom-emacs.md` for the complete installation and verification
  sequence. Install the Emacs application before installing Doom core.
- On macOS, use Railwaycat's stable `emacs-mac@29` from the Brewfile (Doom
  requires 29.1+). Newer Railwaycat `exp` formulas are experimental; do not
  switch to them merely for a higher version number. Recheck upstream advice
  when intentionally changing versions.
- Dynamic modules are enabled by default in the current formula; the older
  Doom guide's `--with-modules` flag is obsolete. Use `brew --prefix emacs-mac@29`
  for the app path, not a hard-coded Intel/Apple Silicon prefix. Never replace
  an existing `/Applications/Emacs.app` without inspecting it and approval.
- Verify the selected CLI Emacs, module support, GUI startup, and `doom doctor`.
  Run `doom sync` after changing the Emacs build/version as well as config.
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
