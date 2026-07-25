# Chuwi MiniBook X — Linux config notes

Machine: CHUWI MiniBook X (BIOS DNN20 V2.22, 2024-06-12)
OS: Arch Linux + Omarchy, Hyprland, Limine bootloader, LUKS-encrypted btrfs root
Panel: 1920x1200 DSI panel physically mounted rotated 90° → everything has to be rotated in software.

This documents the MiniBook-X-specific changes actually present on this box (as of writing).

---

## 1. The core problem: the panel is rotated

The internal display (`DSI-1`) is mounted portrait, so without fixes the whole
stack (firmware menu → boot splash → console → login → desktop → touch) shows up
sideways. Each layer has its own rotation fix.

## 2. Fixes currently in place

### a) Bootloader menu rotation — Limine
File: `/boot/limine.conf`
```
interface_rotation: 90
```
Rotates the Limine boot menu so it's readable in the panel's native orientation.

### b) Kernel / console + Plymouth splash rotation
Kernel cmdline (in the auto-generated Limine entry, EFI stub `omarchy_linux.efi`):
```
video=DSI-1:panel_orientation=right_side_up
```
This tells the i915 DRM driver the panel's real orientation, which fixes the
framebuffer console and the Plymouth boot splash. This is the standard MiniBook X
fix and is applied to every kernel entry incl. snapshots.
(`/proc/cmdline` confirms it's live.)

### c) Wayland / Hyprland display rotation
File: `~/.config/hypr/monitors.conf`
```
env = GDK_SCALE,2
monitor=,1920x1200,auto,1.67,bitdepth,8,transform,3
```
- `transform,3` = rotate 270° (lands the image upright for this panel).
- scale `1.67` + `GDK_SCALE=2` for HiDPI on the small high-res screen.

### d) Touchscreen rotation to match display
File: `~/.config/hypr/input.conf`
```
touchdevice {
  transform = 3
  output = DSI-1
}
```
Without this, touch input is mapped to the un-rotated coordinate space and taps
land in the wrong place.

## 3. Other MiniBook-related tweaks on this box

### modprobe fixes (`/etc/modprobe.d/`)
- `hid_apple.conf`: `options hid_apple fnmode=2` — makes the F-keys behave as
  standard function keys by default (Fn to get media keys). Relevant to the
  MiniBook's compact keyboard.
- `disable-usb-autosuspend.conf`: `options usbcore autosuspend=-1` — disables USB
  autosuspend (common fix to stop flaky USB/peripheral disconnects, esp. the
  internal card reader / dongles).

### Suspend / idle (`~/.config/hypr/hypridle.conf`)
Switched from raw `loginctl` / `dpms` calls to Omarchy's
`omarchy-system-lock` / `omarchy-system-wake` (and `OMARCHY_LOCK_ONLY` before
sleep). Not strictly MiniBook-specific, but it's a change from the default.
Old version kept as `hypridle.conf.bak.1781420413`.

## 4. tablet-mode support — `minibook-support-git` (INSTALLED & ACTIVE)

AUR package `minibook-support-git` (v1.3.1.r14) by petitstrawberry is installed.
Repo: https://github.com/petitstrawberry/minibook-support

**Install:** declared in `packages/arch/minibook.txt`, and the `minibook` package
profile is auto-selected on `chezmoi init` when DMI reports `MiniBook X`. So
`chezmoi apply` installs it via paru/yay. To do it by hand:

```bash
yay -S minibook-support-git
# the AUR .install hook enables keyboardd + tabletmoded automatically; verify:
for s in tabletmoded keyboardd trackpadd; do
  echo "$s: enabled=$(systemctl is-enabled $s 2>&1) active=$(systemctl is-active $s 2>&1)"
done
```

It ships three C daemons + systemd services:

| Daemon        | Service            | State (this box)        | Job |
|---------------|--------------------|-------------------------|-----|
| `tabletmoded` | `tabletmoded.service` | enabled + active     | fold/tablet detection |
| `keyboardd`   | `keyboardd.service`   | enabled + active     | enable/disable keyboard |
| `trackpadd`   | `trackpadd.service`   | disabled but active* | enable/disable trackpad |

*`trackpadd` is pulled in at runtime as a `Requires=` dependency of
`tabletmoded`, so it runs even though it's not directly enabled.

**How it works:** `tabletmoded` reads BOTH `mxc4005` accelerometers directly,
computes the lid open/close angle, and decides if the machine is folded into
tablet mode. When folded it:
- disables the physical keyboard (via `keyboardd`)
- disables the trackpad (via `trackpadd`)
- emits `SW_TABLET_MODE` from a virtual input device so the DE knows it's a
  tablet (e.g. can bring up an on-screen keyboard).

`keyboardd`/`trackpadd` work by creating virtual passthrough input devices and
toggling the passthrough on/off (trackpadd can also calibrate).

Note: it reads the accelerometers directly — **`iio-sensor-proxy` is NOT
installed**, and `tabletmoded`'s `After=iio-sensor-proxy.service` is just
ordering-if-present. Confirmed live via `journalctl -u tabletmoded`.

> Caveat: the AUR `.install` hook still references an old service name `moused`
> (now `trackpadd`), so `systemctl enable moused` in the hook is a no-op. Doesn't
> matter in practice since `trackpadd` is pulled in by `tabletmoded`.

## 5. What is STILL not configured

- **Screen auto-rotation:** minibook-support does tablet-mode (fold) detection
  only — it does NOT rotate the display based on device orientation. Screen
  rotation is still **static** (the `transform,3` fix in section 2c). If we want
  gravity-based auto-rotate, that's a separate setup on top.
- Battery: `BAT0` / `ADP1` present. Keyboard has capslock/numlock/scrolllock LEDs
  but no dimmable keyboard backlight exposed (`/sys/class/leds`).

## 6. If we want screen auto-rotation later (reference)

Stock `iio-sensor-proxy` gets confused by the two accelerometers, so it needs
special handling. Relevant community repos:

- https://github.com/sonnyp/linux-minibook-x — general MiniBook X Linux hub
- https://github.com/rhalkyard/minibook-dual-accelerometer — dual-accel handling
- https://github.com/greymouser/minibook-x-tools — tools/scripts
- https://github.com/knoopx/nix-chuwi-minibook-x — NixOS config reference
- https://github.com/godorowski/Chuwi-Minibook-X-N100-N150-Fedora-KDE-Fixes — rotation fixes (Fedora/KDE)
- https://finalrewind.org/interblag/entry/chuwi-minibook-x-automatic-screen-rotation/ — write-up on auto-rotate
- https://wiki.archlinux.org/title/Chuwi_MiniBook_X_(2023) — Arch wiki page

Note: our unit reports as plain "MiniBook X" (older N-series). Some repos are
N100/N150-specific — check the model before copying fixes.

## 7. Fresh-install checklist

Rebuilding this machine from a clean Omarchy install. Items 1–2 are **manual** (they
live outside `$HOME`, so chezmoi can't do them); 3–4 are handled by `./setup`.

1. **Kernel cmdline** — add `video=DSI-1:panel_orientation=right_side_up`.
   On Omarchy/limine this goes in the kernel entry; re-run the limine entry tool or
   edit `/boot/limine.conf`. Verify: `grep panel_orientation /proc/cmdline`
2. **Bootloader + modprobe** — `interface_rotation: 90` in `/boot/limine.conf`;
   create `/etc/modprobe.d/hid_apple.conf` (`options hid_apple fnmode=2`) and
   `/etc/modprobe.d/disable-usb-autosuspend.conf` (`options usbcore autosuspend=-1`).
3. **Configs** — `./setup` from the repo root. The `minibook` flag auto-detects from
   DMI and symlinks `~/.config/hypr` → `hypr-minibook/` (rotation + touch transform).
4. **Packages** — the auto-selected `minibook` profile installs `minibook-support-git`.

Then re-verify everything with the `machine-setup` skill (`pi/skills/machine-setup/`).

## 8. Quick reference — files touched
| Layer            | File                                   | Key setting |
|------------------|----------------------------------------|-------------|
| Boot menu        | `/boot/limine.conf`                    | `interface_rotation: 90` |
| Kernel/splash    | Limine cmdline (`omarchy_linux.efi`)   | `video=DSI-1:panel_orientation=right_side_up` |
| Desktop display  | `~/.config/hypr/monitors.conf`         | `transform,3`, scale 1.67, `GDK_SCALE=2` |
| Touch            | `~/.config/hypr/input.conf`            | `touchdevice { transform=3; output=DSI-1 }` |
| Keyboard F-keys  | `/etc/modprobe.d/hid_apple.conf`       | `fnmode=2` |
| USB stability    | `/etc/modprobe.d/disable-usb-autosuspend.conf` | `usbcore autosuspend=-1` |
