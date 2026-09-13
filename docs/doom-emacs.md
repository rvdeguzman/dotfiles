# Doom Emacs installation

There are three separate pieces: the Emacs application, Doom core in
`~/.config/emacs`, and personal configuration in `~/.config/doom`. Applying
chezmoi only clones the personal configuration; it does not install Emacs,
Doom core, or Doom packages.

## macOS: install Emacs first

[Doom's macOS guide](https://github.com/doomemacs/doomemacs/blob/master/docs/getting_started.org#on-macos)
ranks Railwaycat's `emacs-mac` first, `emacs-plus` second, and terminal-only
Homebrew `emacs` third. It warns against emacsformacosx.com (including its
Homebrew cask), AquaMacs, and XEmacs.

This repo deliberately selects `railwaycat/emacsmacport/emacs-mac@29`.
Emacs 29.1+ meets Doom's starter-kit minimum; 29 is our version choice, not
Doom's latest recommended version. Consult the upstream
[prerequisites](https://github.com/doomemacs/doomemacs#prerequisites) before
changing versions, and avoid unstable/pre-release builds.

1. Ensure Apple's command-line tools are installed: `xcode-select -p`.
   If missing, run `make xcode-install` and finish the Apple installer. Run
   `make xcode-check` to check the selected tools/SDK and available updates,
   then `make xcode-update LABEL="<exact label>"` to install a selected CLT
   update with confirmation. Keep the tools updated for the installed macOS.
   If native compilation reports `ld: library 'System' not found`, update the
   command-line tools and verify `xcrun --show-sdk-path` before adding SDK-path
   workarounds. See the README's macOS developer tools section for limitations.
2. With Homebrew installed, run `./install-packages` from this repo. This
   explicitly installs the entire Brewfile, including Railwaycat Emacs 29,
   Git, ripgrep, fd, coreutils (GNU ls), findutils, GNU tar, ispell, and TeX
   Live, without upgrading existing packages. TeX Live provides the `latex`
   and `dvisvgm` executables used by Org formula previews. For an Emacs-only
   installation instead:

   ```sh
   brew tap railwaycat/emacsmacport
   brew install git ripgrep fd coreutils findutils gnu-tar ispell texlive
   brew install railwaycat/emacsmacport/emacs-mac@29 --with-native-compilation
   ```

   The current Railwaycat formula enables dynamic modules by default
   (`--without-modules` disables them). Do not copy the older Doom guide's
   `--with-modules` flag. This Brewfile enables native compilation for better
   performance, as recommended by `doom doctor`. It is not a Doom requirement
   and adds compiler dependencies/build time. `--no-upgrade` does not retrofit
   build options onto an existing install: explicitly approve and run
   `brew reinstall railwaycat/emacsmacport/emacs-mac@29 --with-native-compilation`
   when migrating a build without it, then run `doom sync` and restart Emacs.
   Inspect other Emacs installations first; do not force-link over conflicts.
3. Register the GUI application, only if the destination is absent:

   ```sh
   app="$(brew --prefix emacs-mac@29)/Emacs.app"
   if [ ! -d "$app" ]; then
     printf 'Missing Emacs application: %s\n' "$app"
   elif [ -e /Applications/Emacs.app ] || [ -L /Applications/Emacs.app ]; then
     printf 'Inspect existing /Applications/Emacs.app; do not overwrite it.\n'
   else
     ln -s "$app" /Applications/Emacs.app
   fi
   ```

   Using `brew --prefix` supports both Apple Silicon and Intel. An existing
   correct symlink needs no change. Back up a conflicting app only with
   approval before replacing it. See Railwaycat's
   [launch helpers](https://github.com/railwaycat/homebrew-emacsmacport/blob/master/docs/emacs-start-helpers.md).
4. Verify the shell selects the intended Emacs:

   ```sh
   command -v emacs
   emacs --version
   emacs --batch -Q --eval '(princ (list :version emacs-version :modules module-file-suffix))'
   ```

   Expect Emacs 29.1+ and a non-nil module suffix. Fix PATH or Homebrew link
   conflicts explicitly if another Emacs is selected. GNU tools also expose
   prefixed commands (`gls`, `gfind`, `gtar`); do not replace system binaries.

## Install Doom after reviewing and applying the personal config

Follow the README's diff-first chezmoi workflow. Confirm `~/.config/doom` is
its expected Git checkout (`https://github.com/rvdeguzman/doom.git`), preserving
local changes. Before cloning core, inspect both `~/.config/emacs` and
`~/.emacs.d` (including symlinks). Never clone over or delete an existing
installation; agree on a backup/migration first. An existing valid Doom core
checkout should be reused rather than cloned again.

For a fresh core installation, with no conflicting Emacs configuration:

```sh
git clone --depth 1 https://github.com/doomemacs/core ~/.config/emacs
~/.config/emacs/bin/doom install
~/.config/emacs/bin/doom doctor
```

Resolve doctor errors and review warnings. Start `/Applications/Emacs.app`
on macOS and confirm Doom loads. If GUI Emacs is missing shell environment
variables, run `~/.config/emacs/bin/doom sync --env` from the intended shell
and restart Emacs (current Doom core; older versions used `doom env`). Keep generated environment files local; they can contain secrets.

After module/package changes or changing the Emacs build/version, run:

```sh
~/.config/emacs/bin/doom sync
~/.config/emacs/bin/doom doctor
```

Restart Emacs afterward.
