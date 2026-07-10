#!/bin/bash

emacs --daemon 2>/dev/null &
DAEMON_PID=$!

for i in {1..30}; do
  if emacsclient -e '(+ 1 1)' 2>/dev/null; then
    break
  fi
  sleep 0.1
done

emacsclient -c -n &
sleep 0.5
hyprctl dispatch movetoworkspace 2,class:Emacs
