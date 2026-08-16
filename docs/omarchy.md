# Omarchy machine setup

Post-apply steps for Omarchy (Arch + Hyprland) machines. These configure
machine-local state that chezmoi intentionally does not manage.

## Theme

The custom theme lives in the repo at
`home/dot_config/omarchy/themes/vague-black/` (colors.toml + backgrounds +
a theme-specific `ghostty.conf`). It is installed by a normal
`chezmoi apply`; activate it with:

```sh
omarchy theme set vague-black
```

Notes:

- `colors.toml` is the whole color story: Omarchy generates waybar, hyprland,
  hyprlock, terminal, mako, walker, btop, etc. from it via templates.
- `ghostty.conf` inside the theme overrides the generated one so the terminal
  matches the macOS ghostty look (gruvbox-material, 0.9 opacity, blur).
- Backgrounds are pre-letterboxed: full painting centered at max 1400x800 on
  a 1920x1080 black canvas, because Omarchy hardcodes `swaybg -m fill`.
  To add/resize one: `magick in.jpg -resize 1400x800 -background black
  -gravity center -extent 1920x1080 out.jpg`.
- The theme dir is chezmoi-ignored on non-Hyprland machines.

## Defaults (run once per machine)

```sh
omarchy pkg add ghostty            # needs sudo; run interactively
omarchy default terminal ghostty   # SUPER+Return -> ghostty
omarchy default browser brave      # XDG handlers + SUPER+SHIFT+Return
```

These write machine-local files (`~/.config/xdg-terminals.list`,
xdg-settings/mimeapps) that are not tracked by chezmoi — re-run them on each
new machine.

## Verify

```sh
omarchy theme current              # vague-black
xdg-settings get default-web-browser   # brave-browser.desktop
head -3 ~/.config/xdg-terminals.list   # ghostty first
hyprctl configerrors               # empty
```
