#!/bin/bash
MONITOR=$(cat /tmp/.aerospace-focused-monitor 2>/dev/null) || MONITOR=$(aerospace list-monitors --focused --format "%{monitor-id}")
aerospace move-node-to-workspace --focus-follows-window "M${MONITOR}-${1}"
