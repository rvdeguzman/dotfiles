# Clio: local zsh history

[Clio](https://github.com/rvdeguzman/clio) is the user's cut-down Atuin
replacement: a Rust binary and zsh hook providing a local prefix-history picker
on Ctrl-R. No daemon, sync, account, network features, or fzf dependency.

Clio stays a separate, manually managed repository. Dotfiles does not clone it,
build it, import history, or enable its shell hook during setup/apply.

## Install

Requires Rust/Cargo and zsh (Rust is in the macOS Brewfile). On macOS, ensure
Command Line Tools are available with `make xcode-check` in the dotfiles repo.

Reuse `~/repos/clio` if present. Inspect its Git status and origin first; the
expected remote is `https://github.com/rvdeguzman/clio.git`. Preserve local
changes. Only on a new machine where that path does not exist:

```sh
mkdir -p ~/repos
git clone https://github.com/rvdeguzman/clio.git ~/repos/clio
```

Install explicitly from the checkout:

```sh
cd ~/repos/clio
make install
```

This runs `cargo install --path .` and copies the hook to
`${XDG_DATA_HOME:-$HOME/.local/share}/clio/clio.zsh`. Ensure Cargo's binary
directory is on PATH (normally `${CARGO_HOME:-$HOME/.cargo}/bin`; a custom
Cargo install root can change this). Verify `command -v clio` before enabling
the hook.

## Optional history migration — before enabling the hook

```sh
clio import
```

This imports local Atuin and zsh history. Run it **before** sourcing the hook:
the first captured command creates Clio's store, and import refuses an existing
store by default. Do not use `clio import --force` casually: it appends to the
existing history and can repeat previously imported records. Back up private
history before attempting a forced import.

Atuin import requires the `sqlite3` CLI and its local history database; missing
sources are skipped. See Clio's [specification](https://github.com/rvdeguzman/clio/blob/main/SPEC.md)
for import paths and limitations.

## Enable zsh integration explicitly

Back up your existing `~/.zshrc` before editing it; dotfiles intentionally does
not manage that file. If replacing Atuin, disable its initialization/plugin
explicitly rather than letting both tools compete for Ctrl-R. Keep the old
history until migration is verified.

After Oh My Zsh, `bindkey -e`, and other keybinding setup, add:

```zsh
source "${XDG_DATA_HOME:-$HOME/.local/share}/clio/clio.zsh"
```

Start a new zsh. Press Ctrl-R to search: Enter executes a selection, Tab places
it in the command line for editing, and Esc cancels. Prefer Tab when checking
imported commands to avoid accidentally executing one.

## Update

In the clean Clio checkout, review upstream changes, then explicitly run:

```sh
cd ~/repos/clio
git pull --ff-only
make install
```

If the pull fails, resolve the checkout state without discarding local work.
Start a new shell to load the updated hook. Do not re-import history on updates.

## Private machine state

History lives at `${XDG_DATA_HOME:-$HOME/.local/share}/clio/history` and may
contain credentials or other sensitive command text. Never add that directory
to chezmoi, Git, an external checkout, or a sync service. Keep source code in
`~/repos/clio`, separate from runtime data. Do not print history into agent logs
for installation verification.
