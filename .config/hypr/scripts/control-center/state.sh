#!/usr/bin/env bash

# ------------------------------------------------------------
# Wi-Fi
# ------------------------------------------------------------

wifi="unavailable"

if command -v nmcli >/dev/null 2>&1; then
    case "$(nmcli -t -f WIFI general 2>/dev/null)" in
        enabled)
            wifi="on"
            ;;
        disabled)
            wifi="off"
            ;;
    esac
fi


# ------------------------------------------------------------
# Bluetooth
# ------------------------------------------------------------

bluetooth="unavailable"

if command -v bluetoothctl >/dev/null 2>&1; then
    bt_state="$(
        bluetoothctl show 2>/dev/null |
        awk '/Powered:/ {print $2; exit}'
    )"

    case "$bt_state" in
        yes)
            bluetooth="on"
            ;;
        no)
            bluetooth="off"
            ;;
    esac
fi


# ------------------------------------------------------------
# Audio
# ------------------------------------------------------------

audio="unavailable"
volume="0"

if command -v wpctl >/dev/null 2>&1; then
    wp="$(
        wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true
    )"

    if [ -n "$wp" ]; then

        if echo "$wp" | grep -q '\[MUTED\]'; then
            audio="off"
        else
            audio="on"
        fi

        volume="$(
            echo "$wp" |
            awk '{printf "%.0f", $2 * 100}'
        )"
    fi
fi


# ------------------------------------------------------------
# Night Light
# ------------------------------------------------------------

nightlight="unavailable"

if command -v hyprsunset >/dev/null 2>&1; then
    if pgrep -x hyprsunset >/dev/null 2>&1; then
        nightlight="on"
    else
        nightlight="off"
    fi
fi


# ------------------------------------------------------------
# Do Not Disturb
# ------------------------------------------------------------

dnd_file="$HOME/.cache/quickshell/dnd"

if [ "$(cat "$dnd_file" 2>/dev/null)" = "1" ]; then
    dnd="on"
else
    dnd="off"
fi


# ------------------------------------------------------------
# Power profile
# ------------------------------------------------------------

profile="unavailable"

if command -v powerprofilesctl >/dev/null 2>&1; then
    profile="$(
        powerprofilesctl get 2>/dev/null ||
        echo unavailable
    )"
fi


# ------------------------------------------------------------
# JSON
# ------------------------------------------------------------

python3 - \
    "$wifi" \
    "$bluetooth" \
    "$audio" \
    "$volume" \
    "$nightlight" \
    "$dnd" \
    "$profile" <<'PY'
import json
import sys

print(json.dumps({
    "wifi": sys.argv[1],
    "bluetooth": sys.argv[2],
    "audio": sys.argv[3],
    "volume": int(sys.argv[4] or 0),
    "nightlight": sys.argv[5],
    "dnd": sys.argv[6],
    "profile": sys.argv[7]
}))
PY
