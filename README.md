# Dotfiles

macOS-only configuration. `home/` mirrors `$HOME`, and `./dot` copies files
between them: `home/.config/rex/init.lua` installs to `~/.config/rex/init.lua`.
Live files are real copies, not symlinks. Nothing moves in either direction
without an explicit command.

## Setup

Start with [the machine setup runbook](docs/machine-setup.md), including
prerequisite inspection, backups, and functional checks.

```sh
make doctor      # read-only local preflight (requires Python 3)
make diff        # review what apply would change
make apply       # copy differing files into $HOME (backs up overwritten files)
make externals   # clone missing nvim, doom, and pi-config checkouts
make status      # report remaining drift
```

Doctor never installs, fetches, or applies. Failures return a nonzero status;
warnings and skipped checks still need review. See the runbook for fresh
machines without Python/developer tools.

Homebrew is required. Installers and `./dot` reject non-macOS hosts. Previous
Linux configuration is available in Git history, not managed by the current
tree.

### Emacs and Doom

Follow [the Emacs/Doom installation guide](docs/doom-emacs.md): install Emacs
first, apply the personal configuration after reviewing the diff, then install
Doom core and its packages separately. The macOS Brewfile selects Railwaycat's
experimental `emacs-mac@31exp` snapshot (not HEAD), with native compilation,
librsvg, xwidgets, and the CLI GUI starter. Tree-sitter and dynamic modules
(for vterm) are enabled by default. This deliberately uses a pre-release build;
Doom recommends avoiding those. The formula's snapshot can change with tap
updates; the Brewfile does not pin its date.
The guide covers prerequisites, safe GUI app registration, existing-install
checks, and `doom install` / `doom sync` / `doom doctor` verification.

`make externals` clones only `~/.config/doom`; it does **not** install
Emacs or Doom core (`~/.config/emacs`).

## Daily workflow

```sh
make status                      # A = missing in $HOME, M = differs
make diff                        # repo -> $HOME changes that apply would make
make apply                       # copy them; overwritten files go to
                                 # ~/.local/state/dotfiles/backups/<timestamp>/
make sync                        # copy edits to managed live files back into home/,
                                 # then commit with plain git
make apply PATHS=".config/rex"   # limit any command to some paths
```

A managed file is any tracked or untracked, non-ignored file under `home/`.
To start managing a new config, copy it into the matching path under `home/`.
`sync` never adds files, so new live files (including secrets) stay out of the
repo. `apply` never deletes files.

When both sides changed, check which is newer before choosing `apply` or
`sync`; each overwrites the other side.

## Vendored repos

The heavy-churn configs are their own repositories, listed in `externals` and
cloned by `make externals` when missing. Existing checkouts are never touched:

| checkout            | repo                    |
|---------------------|-------------------------|
| `~/.config/nvim`    | rvdeguzman/nvim         |
| `~/.config/doom`    | rvdeguzman/doom         |
| `~/.pi/agent`       | rvdeguzman/pi-config    |

Each is a normal git checkout: edit in place, then commit, pull, and push
there. Everything pi-related lives in pi-config, checked out directly at
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
existing packages, and nothing installs during `make apply`.

Python projects use `uv` for virtual environments and dependencies; it is
included in the Brewfile.

Tools outside Homebrew (`pi`, `herdr`, Oh My Zsh) are installed explicitly by
`./install-extras`.

For NVM-managed Node, explicitly run `make nvm-install`. This installs upstream
NVM v0.40.8 if absent, installs Node 24 LTS, and sets it as NVM's default. Existing
NVM installations are reused without updating; other Node installations are
left untouched. The zsh example uses [Oh My Zsh's built-in NVM lazy loading](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/nvm#lazy-startup):
NVM and its completion load on the first `nvm`, `node`, `npm`, `npx`, `pnpm`,
`pnpx`, `yarn`, or `corepack` command, rather than at shell startup. The first
command pays the initialization cost and activates NVM's default Node. No
custom cache or additional plugin is needed.

Direct scripts using `#!/usr/bin/env node` (and commands such as `env node`)
bypass shell functions: before a trigger runs, they use the existing PATH.
For another Node-based CLI, add its command name to
`zstyle ':omz:plugins:nvm' lazy-cmd ...` **before** sourcing Oh My Zsh, or run
`_omz_nvm_load` explicitly first. `.nvmrc` auto-switching is not enabled.
The example also sources local `~/.config/zsh/secrets.zsh` when present.

Herdr plugins required by the managed configuration are declared separately and
installed explicitly after Herdr itself:

```sh
make herdr-plugins
```

This runs `./install-herdr-plugins`; it currently installs the Vim/Herdr pane
navigation plugin and never runs during `make apply`.

Rex keybindings live in `~/.config/rex/init.lua`. Binding `cmd+h` there also
requires moving the macOS "Hide Rex" menu shortcut, which is an app default:

```sh
make rex-keys
```

This runs `./configure-rex`, which remaps Hide to `ctrl+opt+shift+cmd+h`. Quit
and reopen Rex afterward. Rex.app settings (font, colors, padding) are not managed.

### Clio shell history

[Clio](https://github.com/rvdeguzman/clio) is the personal, local-only Atuin
replacement for zsh. It remains a separate manually managed checkout, not an
external. See [installation and migration instructions](docs/clio.md)
for `make install`, optional history import **before** enabling the hook, and
explicit `~/.zshrc` integration. Shell history stays private and unmanaged.

### macOS developer tools

Maintain Apple's Command Line Tools explicitly (never during apply):

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

## Optional iCloud Drive shortcut

Create `~/icloud` as a symlink to iCloud Drive on each Mac. First enable iCloud
Drive in System Settings and open it in Finder. Then copy and paste:

```sh
(
  target="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
  link="$HOME/icloud"
  if [ ! -d "$target" ]; then
    printf '%s\n' 'iCloud Drive is not available yet; enable it and open Finder first.'
  elif [ -e "$link" ] || [ -L "$link" ]; then
    printf '%s\n' '~/icloud already exists; inspect it before changing anything.'
  else
    ln -s "$target" "$link"
  fi
)
```

The command leaves any existing file, directory, or symlink untouched. Verify
with `readlink "$HOME/icloud"`, then use `cd ~/icloud`. This is only a shortcut;
files still live in iCloud Drive and may need downloading before offline use.
The link is machine-local: `make apply` does not create it. Do not add
iCloud contents to this repository.

## Secrets

`~/.zshrc`, `~/.zshenv`, and `~/.zprofile` are intentionally unmanaged local
files. Secrets go in `~/.config/zsh/secrets.zsh` (start from the managed
`secrets.zsh.example`, then `chmod 600`). `*.local` files are gitignored.
A secret pasted into a managed live config enters `home/` on the next
`make sync`, so review `git diff` before committing.

## Layout

- `home/` mirrors `$HOME`. `home/.config/` contains Aerospace, Ghostty, Herdr,
  Rex, tmux, zsh examples, and other application settings. Aerospace uses
  native commands without helper scripts.
- `home/.config/wallpapers/` keeps the wallpaper collection, installed at
  `~/.config/wallpapers`. Selecting a macOS desktop background is manual.
- `dot` copies between `home/` and `$HOME`; `externals` lists separate config
  repos; `Brewfile` declares packages; `docs/` documents explicit installation
  and verification.

**Syncing machines:** commit and push with plain git; on the other machine
`git pull && make apply`.
