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

This repo deliberately selects `railwaycat/emacsmacport/emacs-mac@31exp`,
matching the current machine's experimental Emacs Mac 31.1.50 installation:

- Formula snapshot: `emacs-31-20260901`, **not HEAD**.
- Options: `--with-native-compilation --with-librsvg --with-xwidgets --with-starter`.
- Tree-sitter and dynamic modules (needed by vterm) are enabled by default.
- Both the CLI and `/Applications/Emacs.app` select 31; Emacs 29.4 remains
  installed but unlinked as a fallback. Fresh installs do not need 29.

This is an intentional experimental-build choice, not a stable release or
Doom's recommendation. Doom's upstream
[prerequisites](https://github.com/doomemacs/core#prerequisites) advise against
pre-release versions such as `.50`; compatibility may lag. Recheck them before
changing versions.

The [formula](https://github.com/railwaycat/homebrew-emacsmacport/blob/master/Formula/emacs-mac@31exp.rb)
uses a fixed source snapshot unless `--HEAD` is requested. The Brewfile selects
the formula and options, **not an immutable snapshot date**: future tap updates
can change what a fresh install builds. Do not add `--HEAD`. Homebrew's receipt
may call the non-HEAD spec `stable`; that does not make this Emacs release stable.

1. Ensure Apple's command-line tools are installed: `xcode-select -p`.
   If missing, run `make xcode-install` and finish the Apple installer. Run
   `make xcode-check` to check the selected tools/SDK and available updates,
   then `make xcode-update LABEL="<exact label>"` to install a selected CLT
   update with confirmation. Keep the tools updated for the installed macOS.
   If native compilation reports `ld: library 'System' not found`, update the
   command-line tools and verify `xcrun --show-sdk-path` before adding SDK-path
   workarounds. See the README's macOS developer tools section for limitations.
2. With Homebrew installed, run `./install-packages` from this repo. This
   explicitly installs the entire Brewfile, including Railwaycat Emacs 31 experimental,
   Git, ripgrep, fd, coreutils (GNU ls), findutils, GNU tar, ispell, and TeX
   Live, without upgrading existing packages. TeX Live provides the `latex`
   and `dvisvgm` executables used by Org formula previews. For an Emacs-only
   installation instead:

   ```sh
   brew tap railwaycat/emacsmacport
   brew install git ripgrep fd coreutils findutils gnu-tar ispell texlive
   brew install railwaycat/emacsmacport/emacs-mac@31exp \
     --with-native-compilation --with-librsvg --with-xwidgets --with-starter
   ```

   The current Railwaycat formula enables tree-sitter and dynamic modules by
   default (`--without-tree-sitter` and `--without-modules` disable them). Do not
   copy the older Doom guide's obsolete `--with-modules` flag. Native compilation
   improves performance but adds compiler dependencies/build time; librsvg adds
   SVG support, xwidgets adds embedded widgets, and starter makes the `emacs`
   command use the app's GUI launcher (use `emacs -nw` for terminal mode).
   Starter does not register `/Applications/Emacs.app`.

   `--no-upgrade` does not retrofit build options onto an existing install.
   Inspect `brew info railwaycat/emacsmacport/emacs-mac@31exp` and
   `brew list --versions emacs-mac@31exp emacs-mac@29` first. If options are
   missing, separately approve a rebuild with all four flags:

   ```sh
   brew reinstall railwaycat/emacsmacport/emacs-mac@31exp \
     --with-native-compilation --with-librsvg --with-xwidgets --with-starter
   ```

   Reinstall uses the current tap formula, which may be a newer snapshot.
   After changing the build/version, run `doom sync` and restart Emacs.
   Inspect other Emacs installations before installing; do not force-link over
   conflicts. If 29 is currently linked, separately approve `brew unlink emacs-mac@29`
   and `brew link emacs-mac@31exp` when switching the CLI. Keep 29 installed if
   it is the fallback; no uninstall or cleanup is required. GUI registration
   is a separate step below.
3. Register the GUI application, only if the destination is absent:

   ```sh
   app="$(brew --prefix emacs-mac@31exp)/Emacs.app"
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
   emacs --batch -Q --eval '(princ (list :version emacs-version :modules module-file-suffix :native-comp (native-comp-available-p) :tree-sitter (treesit-available-p) :svg (image-type-available-p (quote svg)) :xwidgets (featurep (quote xwidget-internal))))'
   ls -l "$(command -v emacs)" /Applications/Emacs.app
   ```

   For the recorded snapshot, expect Emacs 31.1.50, a non-nil module suffix,
   and non-nil feature checks. Confirm both CLI and GUI paths select `31exp`;
   a version string alone does not identify the snapshot or install options.
   Fix PATH or Homebrew link conflicts explicitly if another Emacs is selected.
   In the GUI, also check `M-x emacs-version`, Doom startup, and the features
   you use (including vterm and xwidgets); batch checks do not prove GUI behavior.
   GNU tools expose prefixed commands (`gls`, `gfind`, `gtar`); do not replace
   system binaries.

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
