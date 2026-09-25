#!/usr/bin/env bash

ACTION="${1:-}"

case "$ACTION" in

    wifi)
        if command -v nmcli >/dev/null 2>&1; then
            state="$(nmcli -t -f WIFI general 2>/dev/null)"

            if [ "$state" = "enabled" ]; then
                nmcli radio wifi off
            else
                nmcli radio wifi on
            fi
        fi
        ;;


    bluetooth)
        if command -v bluetoothctl >/dev/null 2>&1; then
            state="$(
                bluetoothctl show 2>/dev/null |
                awk '/Powered:/ {print $2; exit}'
            )"

            if [ "$state" = "yes" ]; then
                bluetoothctl power off >/dev/null
            else
                bluetoothctl power on >/dev/null
            fi
        fi
        ;;


    audio)
        if command -v wpctl >/dev/null 2>&1; then
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        fi
        ;;


    nightlight)
        if command -v hyprsunset >/dev/null 2>&1; then

            if pgrep -x hyprsunset >/dev/null 2>&1; then
                pkill -x hyprsunset
            else
                nohup hyprsunset -t 4000 \
                    >/dev/null 2>&1 &
            fi

        fi
        ;;


    dnd)
        file="$HOME/.cache/quickshell/dnd"

        mkdir -p "$(dirname "$file")"

        if [ "$(cat "$file" 2>/dev/null)" = "1" ]; then
            echo 0 > "$file"
        else
            echo 1 > "$file"
        fi
        ;;


    power-profile)
        if command -v powerprofilesctl >/dev/null 2>&1; then

            current="$(
                powerprofilesctl get 2>/dev/null ||
                echo balanced
            )"

            case "$current" in
                performance)
                    powerprofilesctl set balanced
                    ;;
                *)
                    powerprofilesctl set performance
                    ;;
            esac

        fi
        ;;


    settings)
        bash "$HOME/.config/hypr/scripts/qs_manager.sh" \
            toggle settings
        ;;


    lock)
        bash "$HOME/.config/hypr/scripts/lock.sh"
        ;;


    suspend)
        systemctl suspend
        ;;


    logout)
        hyprctl dispatch exit
        ;;


    reboot)
        systemctl reboot
        ;;


    shutdown)
        systemctl poweroff
        ;;

esac
