#!/usr/bin/env bash

NAME="ave-terminal"
CLASS="ave-scratchpad"

ADDR="$(
    hyprctl clients -j |
    jq -r \
        --arg cls "$CLASS" \
        '.[] |
         select(.class == $cls) |
         .address' |
    head -n1
)"


# ============================================================
# CREATE SCRATCHPAD IF IT DOES NOT EXIST
# ============================================================

if [ -z "$ADDR" ]; then

    hyprctl dispatch exec \
        "[workspace special:$NAME silent; float; size 1100 720; center] kitty --class $CLASS --title 'Scratchpad Terminal'" \
        >/dev/null

    # Wait briefly until Kitty actually creates its Wayland window.
    for _ in $(seq 1 30); do

        sleep 0.05

        ADDR="$(
            hyprctl clients -j |
            jq -r \
                --arg cls "$CLASS" \
                '.[] |
                 select(.class == $cls) |
                 .address' |
            head -n1
        )"

        [ -n "$ADDR" ] && break
    done

    # The window was created silently on the special workspace.
    # Now show that workspace.
    hyprctl dispatch togglespecialworkspace \
        "$NAME" >/dev/null

    exit 0
fi


# ============================================================
# WINDOW EXISTS -> SHOW / HIDE
# ============================================================

hyprctl dispatch togglespecialworkspace \
    "$NAME" >/dev/null

