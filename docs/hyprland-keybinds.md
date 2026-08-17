# Hyprland keybinds — state & drift

Scope: the Hyprland keybind setup on Arch + Omarchy (quattro, Lua config).
The point of this doc is that **most bindings are Omarchy defaults** — only a small
custom layer is ours, and that layer is what must survive a rebuild.

Repo copy: `home/dot_config/hypr/bindings.lua`
Live copy: `~/.config/hypr/bindings.lua`

**Bindings are ours, deliberately.** Omarchy is the source of truth for most config,
but `bindings.lua` is the one file we keep our own version of — the vim-style layer
below is real work; defaults are unbound with `hl.unbind` before rebinding.

## How bindings resolve

Since Omarchy quattro / Hyprland 0.55+, config is Lua. `~/.config/hypr/hyprland.lua`:

1. Loads **Omarchy defaults** via `require("default.hypr.omarchy")` from
   `/usr/share/omarchy/default/hypr/` (bindings for tiling, media, clipboard,
   utilities, apps/webapps). These come from the `omarchy` package, NOT this repo.
2. Then loads **our overrides**: `require("hypr.bindings")` →
   `~/.config/hypr/bindings.lua` (last-wins, so it can `hl.unbind` and rebind).
3. Then `require("default.hypr.toggles")` — runtime toggle flags, untracked state.

The old `.conf` files (`bindings.conf`, `hyprland.conf`, etc.) are dead since the
quattro migration and were removed from this repo.

## Our custom layer

**Unbinds (6)** — clears conflicting Omarchy defaults so the vim layer can take over:
`SUPER` + `W, J, K, L, T, TAB`.

**Vim-style window management** (the core reason for the unbinds):
- `SUPER H/J/K/L` — focus left/down/up/right
- `SUPER SHIFT H/J/K/L` — move window
- `SUPER Q` — close window
- `SUPER R` — enter a `resize` submap (`hl.define_submap`), then `H/J/K/L` to
  resize, `Esc`/`Return` to exit

**Reassigned**: `SUPER Z` toggle floating · `SUPER D` file manager (nautilus) ·
`SUPER TAB` former workspace

**Launchers — Omarchy defaults, deliberately kept**: `SUPER SPACE` Omarchy root
menu · `SUPER ALT SPACE` Apps menu (walker is gone; `omarchy-menu` replaced it).

All app/webapp launchers (`SUPER SHIFT` + letter) are stock Omarchy defaults now;
we no longer carry our own copies.

## Non-keybind files

- `input.lua.tmpl` — ours: `ctrl:nocaps`, repeat 40/250, numlock, clickfinger,
  `scroll_factor 0.4`, terminal `scroll_touchpad` rules; MiniBook branch adds the
  touch `transform = 3` for the rotated panel.
- `looknfeel.lua` — ours: i3-like (gaps 4, border 2, rounding 0, no blur/shadow,
  no animations).
- `monitors.lua.tmpl` — MiniBook branch: `1920x1200`, scale 1.67, `transform = 3`;
  otherwise preferred @ 1.6 with `GDK_SCALE=2`.
- `hypridle.conf`, `hyprlock.conf`, `hyprsunset.conf`, `xdph.conf` — still
  hyprlang `.conf`; read by separate processes, unchanged by the Lua migration.

## Caveats

- `~/.config/hypr` is a **real directory, not a symlink**: this repo uses chezmoi
  copy mode. Use `chezmoi diff`/`dot apply` to review and apply repo changes.
- Two variants share `home/dot_config/hypr/` selected by the `minibook` flag via
  `.tmpl` conditionals in `input.lua.tmpl` and `monitors.lua.tmpl`.
- After changes: `hyprctl reload && hyprctl configerrors` must be clean.

## Re-run the audit

```bash
diff ~/repos/dotfiles/home/dot_config/hypr/bindings.lua ~/.config/hypr/bindings.lua
chezmoi diff                                     # expect empty for .config/hypr
omarchy menu keybindings --print | grep -E "SUPER \+ (Q|D|H|J|K|L|Z|R|TAB) "
hyprctl reload && hyprctl configerrors           # expect ok / empty
```
