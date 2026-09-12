# Machine setup runbook

Use this order for humans and agents. Start in the dotfiles checkout and read
`AGENTS.md`. macOS is the main path below; Linux support is still present and
must not be removed or applied to unrelated hardware by assumption.

## 1. Inspect without changing anything

```sh
git status --short
make doctor
```

`make doctor` requires Python 3; Python 3.11+ enables TOML-based external checks.
If Python or make is missing on a fresh Mac, perform the prerequisite inspection
manually before approving their installation. Doctor is not a bootstrapper.

Doctor checks OS/architecture, tools on PATH, selected macOS developer tools/SDK,
local Homebrew package presence, Git checkout roots/origins/local changes,
Doom core, common configuration conflicts, and chezmoi managed-file drift.
External targets come from `home/.chezmoiexternal.toml`, not a duplicated list.
Equivalent GitHub HTTPS and SSH origins are accepted. It does not inspect the
contents of shell configs, secrets, history, or generated Doom environments.

- `[FAIL]`: prerequisite/check failed or checkout conflicts need resolution;
  exit status 1. Command timeouts also produce failed/incomplete checks.
- `[WARN]`: missing optional packages, drift, local changes, or skipped checks;
  exit status remains 0 if there are no failures. **Zero does not mean setup is
  complete or that applying changes is approved.**
- No installs, update scans, network fetches, builds, or apply operations.
  Git optional locks and Homebrew automatic updates/analytics are disabled.
  ChezMoi status uses dry-run, no external refresh, excludes externals, and
  skips secret templates. Error details and changed paths are suppressed.
- Package presence is not version/build-option verification. GUI behavior,
  native compilation, fonts, and interactive shell integration require manual
  follow-up. Linux package profiles are not automatically audited.

Also establish the intended machine role and optional tools with the user.
Do not print secrets or history to diagnose installation. Preserve unrelated
work in this checkout and external repositories.

**Approval checkpoint:** summarize missing prerequisites, conflicting paths,
requested features, and proposed changes before installing or replacing anything.

## 2. Prerequisites and explicit package installation

### macOS

1. Check `xcode-select -p`. If tools are missing, approve and run
   `make xcode-install`, then finish Apple's GUI installer.
2. For existing tools, `make xcode-check` lists available CLT updates (this step
   contacts Apple's update service, unlike doctor). Install only an approved
   exact label with `make xcode-update LABEL="<label>"`. Full Xcode is separate;
   do not switch its selected developer directory implicitly.
3. Inspect existing Homebrew and architecture; use the official
   [Homebrew installation instructions](https://brew.sh/) if absent. Ensure
   the intended Homebrew is on PATH; do not introduce a second installation
   or replace user shell configuration to solve PATH problems.
4. Review `packages/macos/Brewfile`, then explicitly approve and run
   `./install-packages`. It installs the full list with `--no-upgrade`.
   Existing Emacs builds may require a separately approved reinstall to enable
   native compilation; see [Doom setup](doom-emacs.md).
5. Review `install-extras` before running it with approval. It installs missing
   pi, Herdr, and Oh My Zsh, and uses downloaded installer scripts. Do not assume
   these tools are installed just because their configuration is present.

### Arch / Omarchy

Inspect `packages/arch/*.txt`. Approve `./install-packages base` plus only
profiles appropriate for the actual machine. Never select `minibook` on other
hardware or modify Omarchy's own source. Follow `docs/minibook-x.md` only when
applicable; migration steps there are not generic fresh-install commands.

The user must handle sudo/password/conflict prompts directly in their terminal.
Never request, capture, store, or pipe their password. Stop on package conflicts;
explain any proposed replacement and obtain approval.

## 3. Initialize chezmoi — no full apply yet

```sh
./setup
```

This can install chezmoi if missing and initializes its source; it does not
apply configuration. Linux prompts determine desktop/hardware configuration.
Inspect the existing `~/.local/bin/dot` before replacing it. With approval,
bootstrap only the wrapper:

```sh
chezmoi apply ~/.local/bin/dot
```

Ensure `~/.local/bin` is on PATH, or invoke the installed wrapper by its full
path. Do not run a full apply to bootstrap the wrapper.

## 4. Review changes, external targets, and backups

Run `dot diff` (or `chezmoi diff`) locally. Summarize **every affected area**,
including scripts, application configs, and external checkouts. Avoid copying
sensitive diff content into chat. A reviewed diff is not approval to apply it.

Inspect every target in `home/.chezmoiexternal.toml` before applying. Each
existing target must be an actual Git working-tree root with its expected
origin. A nested directory, bare repo, unrelated origin, or ad-hoc local commit
is not enough. Preserve dirty checkouts; do not force-reset or pull over them.
Never attach a remote to a directory tracking auth, sessions, caches, or history.

For any conflicting path, get approval for the specific backup and replacement:

- Choose a timestamped backup outside managed paths, preferably under a private
  backup directory created with `umask 077` (directory mode `700`).
- Copy with `cp -a` before making changes. Restrict copied data to the user;
  take care not to follow symlinks and alter their referents' permissions.
- Verify the copy and record source, backup path, time, and the intended restore
  procedure in a local private manifest. Do not commit backups or their content.
- Preserve only required ignored machine state when repairing an external repo.
- Restore only with approval: preserve the current replacement first, then copy
  the verified backup back. Never blindly overwrite post-install user changes.

**Approval checkpoint:** present the final diff summary and any backup plan.
Only after approval:

```sh
dot apply
chezmoi status
```

Use a targeted `chezmoi apply <path>` when only one managed file is intended.
Report errors and remaining drift. Do not hide failures by forcing an apply.

## 5. Install application layers and shell integration

- **Doom:** follow [doom-emacs.md](doom-emacs.md). Emacs, personal Doom config,
  Doom core, and Doom packages are separate layers. Inspect both
  `~/.config/emacs` and `~/.emacs.d` first. Reuse a valid existing core checkout;
  never clone over one. Install packages or run `doom sync` as appropriate.
- **Clio:** follow [clio.md](clio.md). Its source remains a separate manually
  managed checkout. `make install` is explicit. Optional history import must
  precede enabling the hook; never import or print history automatically.
- **zsh:** `~/.zshrc`, `~/.zshenv`, and `~/.zprofile` are unmanaged. Back up and
  review before any explicit copy from `home/dot_config/zsh/zshrc.example`.
  Verify Oh My Zsh first. Prefer merging needed lines over replacing an existing
  shell setup. Clio binds Ctrl-R; inspect competing Atuin/plugin bindings.
- **Secrets:** create/populate local secrets interactively, not in agent output.
  Keep `~/.config/zsh/secrets.zsh` mode `600`, outside Git. Generated environment
  snapshots can contain secrets too.

## 6. Verify and hand off

Run `make doctor` again and account for every failure, warning, and skipped
check. Then perform the relevant functional checks:

- New interactive shell: intended Homebrew, `~/.local/bin`, Cargo binaries, and
  Doom CLI resolve correctly; startup has no errors.
- Emacs: intended version, dynamic modules, and a real native compilation test
  if enabled; `doom sync` and `doom doctor` succeed. Open the GUI and confirm
  Doom loads. Restart existing Emacs processes after rebuilding.
- Clio: Ctrl-R opens the picker; Tab edits a selection and Esc cancels. Do not
  execute an arbitrary history entry as a test.
- Terminal/editor fonts render correctly; application availability alone is
  not proof of correct font configuration.
- Aerospace: accessibility permissions, configuration loading, and workspace
  bindings work. Do not treat package installation as permission approval.
- On Linux, after applied Hyprland changes run `hyprctl reload` and
  `hyprctl configerrors`; after Waybar changes restart it with the command for
  the installed Omarchy version.
- `chezmoi status` shows only understood remaining drift. External Git changes
  remain intact. No secrets, caches, or history were staged.

Report what changed, verification results, remaining optional tools/drift,
backup locations (not contents), and actions requiring the user. Do not claim
GUI or interactive checks passed unless actually observed.

## Updates are separate operations

Do not rerun a broad bootstrap or upgrade everything to fix one tool. Review
and approve each: Homebrew package upgrades, CLT updates, external-repo pulls,
Doom changes plus `doom sync`, or Clio pull plus `make install`. ChezMoi apply
can refresh external repos; review their state first. Preserve version choices
and local work, and consult each tool's current upgrade instructions.
