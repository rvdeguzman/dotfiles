-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Legacy Vim-style window management (migrated from bindings.conf).
-- These replace conflicting Omarchy defaults.
hl.unbind("SUPER + W")     -- was: close window (now SUPER+Q)
hl.unbind("SUPER + J")     -- was: toggle window split
hl.unbind("SUPER + K")     -- was: show key bindings
hl.unbind("SUPER + L")     -- was: toggle workspace layout
hl.unbind("SUPER + T")     -- was: toggle floating/tiling (now SUPER+Z)
hl.unbind("SUPER + TAB")   -- was: next workspace

o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
o.bind("SUPER + D", "File manager", { launch = "nautilus --new-window" })
o.bind("SUPER + H", "Focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus right", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + SHIFT + H", "Move window left", hl.dsp.window.move({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Move window down", hl.dsp.window.move({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Move window up", hl.dsp.window.move({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Move window right", hl.dsp.window.move({ direction = "r" }))
o.bind("SUPER + Z", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + TAB", "Previous workspace", hl.dsp.focus({ workspace = "previous" }))

-- Resize mode: SUPER+R, then H/J/K/L; Escape or Return exits.
o.bind("SUPER + R", "Resize mode", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
  hl.bind("H", hl.dsp.window.resize({ x = -25, y = 0, relative = true }), { repeating = true })
  hl.bind("J", hl.dsp.window.resize({ x = 0, y = 25, relative = true }), { repeating = true })
  hl.bind("K", hl.dsp.window.resize({ x = 0, y = -25, relative = true }), { repeating = true })
  hl.bind("L", hl.dsp.window.resize({ x = 25, y = 0, relative = true }), { repeating = true })
  hl.bind("escape", hl.dsp.submap("reset"))
  hl.bind("return", hl.dsp.submap("reset"))
end)
