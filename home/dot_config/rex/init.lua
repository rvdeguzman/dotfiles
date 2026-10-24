-- Rex config — ported from ~/.config/ghostty/config
-- Only keybindings live here. Font, colors, padding, cursor and option-as-alt
-- are Rex.app settings (Settings… / cmd+,), not part of init.lua.
--
-- Check:  rex config check
-- Apply:  rex config reload
-- Verify: rex keymap

-- ctrl+cmd+h/j/k/l resize splits (ghostty used hyper+arrows: resize_split:<dir>,100).
-- Rex's amount is a percentage of the split, not pixels; 5 is Rex's default.
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+cmd+" .. key, "pane.resize", { direction = dir, amount = 5 })
end

-- ctrl+h/j/k/l move between splits (ghostty: performable:ctrl+h=goto_split:left …).
-- Unlike Ghostty's `performable:`, Rex always takes these keys, even with no split
-- in that direction, so programs never see ctrl+h/j/k/l.
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, "pane.focus", { direction = dir, wrap = false })
end

-- cmd+h/l also move left/right between splits (cmd+j/k keep Rex's defaults;
-- use ctrl+j/k to move up/down). macOS's app-menu "Hide" (cmd+h) can't be changed from
-- init.lua; it's moved to ctrl+opt+shift+cmd+h via a per-app menu override
-- (takes effect after quitting and reopening Rex):
--   defaults write com.superlogical.rex NSUserKeyEquivalents \
--     -dict "Hide Rex Beta" '@~^$h' "Hide Rex" '@~^$h'
-- Undo: defaults delete com.superlogical.rex NSUserKeyEquivalents
for key, dir in pairs({ h = "left", l = "right" }) do
  rex.bind("cmd+" .. key, "pane.focus", { direction = dir, wrap = false })
end

-- cmd+k opens the session switcher ("Change Session…").
rex.bind("cmd+k", "session.switch")

-- cmd+o shows the Activity sidebar (in addition to Rex's default cmd+.).
rex.bind("cmd+o", "client.sidebar.activity.toggle")
