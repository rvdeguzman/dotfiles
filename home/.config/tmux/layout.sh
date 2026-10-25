#!/usr/bin/env bash
# tmux layout: 3 windows with custom pane splits
# Session name is set automatically by session-created hook in tmux.conf

SESSION="$(tmux new-session -d -n "main" -P -F '#{session_id}')"

tmux new-window -t "$SESSION" -n "agents"
tmux split-window -h -t "$SESSION"

tmux send-keys -t "$SESSION:1.0" 'nvim' Enter

tmux send-keys -t "$SESSION:2.0" 'claude' Enter
tmux send-keys -t "$SESSION:2.1" 'codex' Enter


tmux new-window -t "$SESSION" -n "server"
tmux split-window -h -t "$SESSION"
tmux split-window -v -t "$SESSION"

tmux send-keys -t "$SESSION:3.2" 'lazygit' Enter

tmux select-window -t "$SESSION:1"
tmux select-pane -t "$SESSION" -L

tmux attach-session -t "$SESSION"
