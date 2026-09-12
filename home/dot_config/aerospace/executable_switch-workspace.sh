#!/bin/bash
MONITOR=$(cat /tmp/.aerospace-focused-monitor 2>/dev/null) || MONITOR=$(aerospace list-monitors --focused --format "%{monitor-id}")
aerospace workspace "M${MONITOR}-${1}"
