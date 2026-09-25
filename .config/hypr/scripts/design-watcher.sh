#!/usr/bin/env bash

CONFIG="$HOME/.config/hypr/design.json"
APPLY="$HOME/.config/hypr/scripts/apply-design.sh"

"$APPLY"

while true; do

    inotifywait \
        -qq \
        -e close_write,modify \
        "$CONFIG"

    sleep 0.05

    "$APPLY"

done
