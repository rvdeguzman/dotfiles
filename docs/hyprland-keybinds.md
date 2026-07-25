# Hyprland keybinds — state & drift

Scope: the Hyprland keybind setup on the MiniBook X (Arch + Omarchy).
The point of this doc is that **most bindings are Omarchy defaults** — only a small
custom layer is ours, and that layer is what must survive a rebuild.

Repo copy: `hypr-minibook/bindings.conf` (top-level, symlinked to `~/.config/hypr`)
Live copy: `~/.config/hypr/bindings.conf`

**Bindings are ours, deliberately.** Omarchy is the source of truth for most config,
but `bindings.conf` is the one file we keep our own version of — the vim-style layer
below is real work and Omarchy's defaults are additive/unbindable, so ours wins.

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

Checked with `diff ~/repos/dotfiles/hypr-minibook/bindings.conf ~/.config/hypr/bindings.conf`.

Result: **essentially no keybind drift.** All 14 unbinds identical; the vim layer,
resize submap, and every app/webapp binding matched. Three lines differed, two now
reconciled into the repo:

| Item | Live | Repo (was) | Resolution |
|---|---|---|---|
| `SUPER SHIFT ALT M` Music TUI (cliamp) | present | **missing** | added to repo |
| `SUPER S` toggle split | `layoutmsg, togglesplit` | `togglesplit,` | repo fixed to `layoutmsg` |
| `SUPER SHIFT O` Obsidian launch flags | plain `obsidian` | `-disable-gpu --enable-wayland-ime` | **repo wins** (ours, deliberate) |

On `SUPER S`: `layoutmsg, togglesplit` is the correct/canonical form — it's what
Omarchy's own `tiling-v2.conf` uses, and `hyprctl binds` confirms the live bind
resolves to `dispatcher: layoutmsg / arg: togglesplit` on Hyprland 0.55.2.

**Obsidian flags — resolved in the repo's favour.** The repo carries `-disable-gpu
--enable-wayland-ime`; live had neither. Those flags exist for real reasons (Wayland IME
input, GPU workaround) and bindings are ours, so the repo version is authoritative. Live
will pick them up on the next apply.

## Non-keybind files: Omarchy is source of truth

These were synced **from live into the repo**, because live reflects current Omarchy:

- `input.conf` — adds `foot` to the terminal scroll rule → `(Alacritty|kitty|foot)`
  (still carries our touch `transform = 3`, which is ours to keep)
- `hyprland.conf` — sources `~/.local/state/omarchy/toggles/hypr/*.conf`
- `hypridle.conf` — uses `omarchy-system-lock` / `omarchy-system-wake` instead of the
  older `loginctl` / `dpms` calls. See `docs/minibook-x.md`.

## Caveats

- `~/.config/hypr` on this machine is currently a **real directory, not a symlink** —
  chezmoi was never initialized here (`~/.config/chezmoi/chezmoi.toml` absent), so live
  and repo can drift silently. After the first `./setup` it becomes a symlink and this
  class of drift goes away.
- Two variants exist and are **mutually exclusive**, selected by the `minibook` flag:
  - `hypr-minibook/` → Omarchy-style split config, rotated panel (this machine)
  - `hypr/` → older vanilla-Arch monolithic config (`$mainMod`, wofi/mako, 240Hz desktop)

  Both target `~/.config/hypr` via `home/dot_config/symlink_hypr.tmpl`. Make sure you
  diff against the right one.

## Re-run the audit

```bash
diff ~/repos/dotfiles/hypr-minibook/bindings.conf ~/.config/hypr/bindings.conf
grep -c '^bind' ~/.config/hypr/bindings.conf     # expect 45 bind lines
hyprctl binds | grep -c bindd                    # effective total incl. omarchy defaults
cd ~/.local/share/omarchy && git status --short   # empty => defaults unmodified
```
