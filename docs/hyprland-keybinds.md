# Hyprland keybinds — state & drift

Scope: the Hyprland keybind setup on the MiniBook X (Arch + Omarchy).
The point of this doc is that **most bindings are Omarchy defaults** — only a small
custom layer is ours, and that layer is what must survive a rebuild.

Repo copy: `home/dot_config/hypr-minibook/bindings.conf`
Live copy: `~/.config/hypr/bindings.conf`

## How bindings resolve

`~/.config/hypr/hyprland.conf` sources, in order:

1. **Omarchy defaults** from `~/.local/share/omarchy/default/hypr/bindings/`:
   `media.conf`, `clipboard.conf`, `tiling-v2.conf`, `utilities.conf`
   → These come from the `omarchy` package, NOT this repo. Verified pristine
   (`git status` in `~/.local/share/omarchy` is clean), so they're reproducible by
   installing Omarchy — no need to vendor them here.
2. **Our overrides**: `~/.config/hypr/bindings.conf` (last-wins, so it can `unbind`
   and rebind over the defaults).
3. `~/.local/state/omarchy/toggles/hypr/*.conf` — runtime toggle flags. Currently only
   a placeholder comment file, no bindings. Runtime state, intentionally untracked.

Note Omarchy ships both `tiling.conf` and `tiling-v2.conf`; we source **v2** only.

## Our custom layer

45 bind lines + 14 unbinds. The shape of it:

**Unbinds (14)** — clears conflicting Omarchy defaults so the vim layer can take over:
`SUPER` + `W, J, K, T, SPACE, S, TAB, O, L, G` and
`SUPER ALT` + `S, G`, `SUPER SHIFT TAB`, `SUPER CTRL TAB`.

**Vim-style window management** (the core reason for the unbinds):
- `SUPER H/J/K/L` — focus left/down/up/right
- `SUPER SHIFT H/J/K/L` — move window
- `SUPER Q` — close window
- `SUPER R` — enter a `resize` submap, then `H/J/K/L` to resize, `Esc`/`Return` to exit

**Reassigned**: `SUPER SPACE` toggle floating · `SUPER Z` launcher (walker) ·
`SUPER S` toggle split · `SUPER TAB` last workspace

**Apps**: `SUPER RETURN` terminal · `SUPER ALT RETURN` terminal+tmux ·
`SUPER SHIFT RETURN`/`B` browser · `SUPER SHIFT F` files (`+ALT` at cwd) ·
`SUPER SHIFT N` editor · `SUPER SHIFT M` Spotify (`+ALT` cliamp TUI) ·
`SUPER SHIFT D` lazydocker · `SUPER SHIFT G` Signal · `SUPER SHIFT O` Obsidian ·
`SUPER SHIFT W` Typora · `SUPER SHIFT /` show keybindings

**Webapps**: `SUPER SHIFT A` ChatGPT (`+ALT` Grok) · `SUPER SHIFT C` Claude ·
`SUPER SHIFT E` email · `SUPER SHIFT Y` YouTube · `SUPER SHIFT P` Google Photos ·
`SUPER SHIFT X` X (`+ALT` compose) · `SUPER SHIFT ALT G` WhatsApp ·
`SUPER SHIFT CTRL G` Google Messages

## Drift audit (live vs repo)

Checked with `diff ~/repos/dotfiles/home/dot_config/hypr-minibook/bindings.conf ~/.config/hypr/bindings.conf`.

Result: **essentially no keybind drift.** All 14 unbinds identical; the vim layer,
resize submap, and every app/webapp binding matched. Three lines differed, two now
reconciled into the repo:

| Item | Live | Repo (was) | Resolution |
|---|---|---|---|
| `SUPER SHIFT ALT M` Music TUI (cliamp) | present | **missing** | added to repo |
| `SUPER S` toggle split | `layoutmsg, togglesplit` | `togglesplit,` | repo fixed to `layoutmsg` |
| `SUPER SHIFT O` Obsidian launch flags | plain `obsidian` | `-disable-gpu --enable-wayland-ime` | **unresolved — see below** |

On `SUPER S`: `layoutmsg, togglesplit` is the correct/canonical form — it's what
Omarchy's own `tiling-v2.conf` uses, and `hyprctl binds` confirms the live bind
resolves to `dispatcher: layoutmsg / arg: togglesplit` on Hyprland 0.55.2.

**Open question — Obsidian flags.** The repo carries `-disable-gpu
--enable-wayland-ime`; live has neither. Those flags exist for a reason (Wayland IME
input, GPU workaround), so this is a real decision, not drift to auto-fix: either live
regressed and should get them back, or they were dropped deliberately. Left as-is
pending a call.

## Other (non-keybind) drift, for the record

- `input.conf`: live adds `foot` to the terminal scroll rule → `(Alacritty|kitty|foot)`.
- `hyprland.conf`: live sources `~/.local/state/omarchy/toggles/hypr/*.conf`; repo doesn't.
- `hypridle.conf`: live uses `omarchy-system-lock`/`omarchy-system-wake`; repo has the
  older `loginctl`/`dpms` version. See `docs/minibook-x.md`.

## Caveats

- `~/.config/hypr` on this machine is a **real directory, not a symlink** — chezmoi was
  never initialized here (`~/.config/chezmoi/chezmoi.toml` absent), so live and repo can
  drift silently. Re-run the audit before trusting the repo copy.
- The repo also has a `home/dot_config/hypr/` variant (older monolithic style, e.g.
  `bind = $mainMod, S, togglesplit`). The MiniBook uses **`hypr-minibook`**; don't
  confuse the two when diffing.

## Re-run the audit

```bash
diff ~/repos/dotfiles/home/dot_config/hypr-minibook/bindings.conf ~/.config/hypr/bindings.conf
grep -c '^bind' ~/.config/hypr/bindings.conf     # expect 45 bind lines
hyprctl binds | grep -c bindd                    # effective total incl. omarchy defaults
cd ~/.local/share/omarchy && git status --short   # empty => defaults unmodified
```
