# Reversible tmux agent-lite layer for Rafael/Frieren.
# Disable by commenting the source-file line in ~/.config/tmux/tmux.conf.
#
# Keys:
#   C-a s    fuzzy tmux/zoxide session search via sesh
#   C-a H    harpoon-style pinned project/session jump
#   C-a G    add current pane directory to harpoon.tsv
#   C-a u    jump to next pending agent notification
#   C-a U    ack/clear pending notifications for current pane
#   C-a M    show pending notification popup
#   C-a O    show detected agent/status popup
#   C-a C-u  ack/clear all pending notifications

# Project/session search: sesh combines tmux sessions + zoxide paths.
bind s display-popup -E -w 80% -h 70% -d "#{pane_current_path}" "/Users/rv/.local/bin/tmux-sesh"

# Harpoon-lite: pinned project/session switcher backed by ~/.config/tmux/harpoon.tsv.
bind H display-popup -E -w 72% -h 62% -d "#{pane_current_path}" "/Users/rv/.local/bin/tmux-harpoon"

# Add the current pane's directory to the harpoon list without prompting.
bind G run-shell "/Users/rv/.local/bin/tmux-harpoon add '#{pane_current_path}'"

# Bellmux attention queue: jump to the next pane where an agent/build requested attention.
bind u run-shell '
  result="$(bellmux next --current "#{pane_id}" 2>/dev/null || true)"
  pane="${result%% *}"
  tag="${result#* }"
  if [ -z "$result" ] || [ -z "$pane" ]; then
    tmux display-message "No pending agent notifications"
    exit 0
  fi
  if [ "$tag" = "$result" ]; then tag=""; fi
  tmux switch-client -t "$pane"
  if [ "$tag" = wrapped ]; then
    tmux display-message "Cycled through all pending agent notifications"
  fi
'

# Clear notifications for the current pane once you've looked at it.
bind U run-shell 'bellmux ack-pane --pane-id "#{pane_id}" && tmux refresh-client -S && tmux display-message "Acked agent notifications for #{pane_id}"'

# Clear notifications everywhere. Kept off X/N to avoid clobbering your existing kill/next-session binds.
bind C-u run-shell 'bellmux ack-all && tmux refresh-client -S && tmux display-message "Cleared all agent notifications"'

# Small pending list popup.
bind M display-popup -E -w 80% -h 60% -d "#{pane_current_path}" "/Users/rv/.local/bin/tmux-bellmux-popup"

# Full status popup: pending queue + detected Claude/Codex/Gemini/etc panes.
bind O display-popup -E -w 88% -h 72% -d "#{pane_current_path}" "/Users/rv/.local/bin/tmux-agent-status | less -R"

# Drop notifications for panes that have died, so jumps never point at ghosts.
set-hook -g pane-died 'run-shell "bellmux prune-pane --pane-id #{pane_id} >/dev/null 2>&1 || true"'

# Minimal status indicator:
#   🔔 = the current pane is pending
#   ●  = another pane is pending
#   empty = no pending Bellmux notifications
set -g status-interval 2
set-option -g status-right "#{?#(bellmux status --only-pane #{pane_id} --format here),#[fg=#b36d43,bold]🔔 #[fg=#666666]#S,#{?#(bellmux status --format='●'),#[fg=#b36d43]● #[fg=#666666]#S,#[fg=#666666]#S}}"
