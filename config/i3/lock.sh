#!/bin/sh

BLANK='#28282800'           # Gruvbox dark bg (transparent)
CLEAR='#28282822'           # Gruvbox dark bg (semi-transparent)
DEFAULT='#83a59888'         # Gruvbox blue (semi-transparent)
TEXT='#ebdbb2ff'            # Gruvbox light fg
WRONG='#fb493488'           # Gruvbox bright red (semi-transparent)
VERIFYING='#b8bb2688'       # Gruvbox bright green (semi-transparent)

i3lock \
--insidever-color=$CLEAR     \
--ringver-color=$VERIFYING   \
\
--insidewrong-color=$CLEAR   \
--ringwrong-color=$WRONG     \
\
--inside-color=$BLANK        \
--ring-color=$DEFAULT        \
--line-color=$BLANK          \
--separator-color=$DEFAULT   \
\
--verif-color=$TEXT          \
--wrong-color=$TEXT          \
--time-color=$TEXT           \
--date-color=$TEXT           \
--layout-color=$TEXT         \
--keyhl-color=$WRONG         \
--bshl-color=$WRONG          \
\
--screen 1                   \
--blur 5                     \
--clock                      \
--indicator                  \
--time-str="%H:%M"        \
--date-str="%Y-%m-%d"    \
