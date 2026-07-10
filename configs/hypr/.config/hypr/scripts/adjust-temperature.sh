#!/bin/bash

TEMP_FILE="/tmp/hyprsunset_temp"
MIN_TEMP=3000
MAX_TEMP=6000
STEP=300

if [ ! -f "$TEMP_FILE" ]; then
    CURRENT_TEMP=6500
else
    CURRENT_TEMP=$(cat "$TEMP_FILE")
fi

if [ "$1" == "up" ]; then
    NEW_TEMP=$((CURRENT_TEMP + STEP))
    if [ $NEW_TEMP -gt $MAX_TEMP ]; then
        NEW_TEMP=$MAX_TEMP
    fi
elif [ "$1" == "down" ]; then
    NEW_TEMP=$((CURRENT_TEMP - STEP))
    if [ $NEW_TEMP -lt $MIN_TEMP ]; then
        NEW_TEMP=$MIN_TEMP
    fi
else
    exit 1
fi

echo $NEW_TEMP > "$TEMP_FILE"
pkill -f "hyprsunset"
sleep 0.1
hyprsunset -t $NEW_TEMP &

if [ $NEW_TEMP -eq $MIN_TEMP ]; then
    notify-send -u low "Min Temperature Reached"
elif [ $NEW_TEMP -eq $MAX_TEMP ]; then
    notify-send -u low "Max Temperature Reached"
fi
