#!/usr/bin/env bash

STATE="${XDG_RUNTIME_DIR:-/tmp}/ave-hypr-spotlight-${HYPRLAND_INSTANCE_SIGNATURE:-default}.json"

ACTIVE="$(hyprctl activewindow -j 2>/dev/null)"

ADDR="$(jq -r '.address // empty' <<< "$ACTIVE")"

if [ -z "$ADDR" ] || [ "$ADDR" = "0x0" ]; then
    exit 0
fi


restore_window() {
    local state_addr
    local was_floating
    local was_pinned
    local x
    local y
    local w
    local h

    [ -f "$STATE" ] || return 0

    state_addr="$(jq -r '.address' "$STATE")"

    # Window may already be closed.
    if ! hyprctl clients -j |
        jq -e --arg a "$state_addr" \
        '.[] | select(.address == $a)' \
        >/dev/null 2>&1
    then
        rm -f "$STATE"
        return 0
    fi

    was_floating="$(jq -r '.floating' "$STATE")"
    was_pinned="$(jq -r '.pinned' "$STATE")"

    x="$(jq -r '.x' "$STATE")"
    y="$(jq -r '.y' "$STATE")"

    w="$(jq -r '.w' "$STATE")"
    h="$(jq -r '.h' "$STATE")"

    # Focus stored window so active-only dispatchers are reliable.
    hyprctl dispatch focuswindow \
        "address:$state_addr" >/dev/null

    # We pinned it ourselves only if it wasn't pinned before.
    if [ "$was_pinned" != "true" ]; then
        hyprctl dispatch pin active >/dev/null 2>&1 || true
    fi

    if [ "$was_floating" = "true" ]; then

        hyprctl dispatch resizeactive \
            "exact $w $h" >/dev/null

        hyprctl dispatch moveactive \
            "exact $x $y" >/dev/null

    else

        hyprctl dispatch settiled \
            "address:$state_addr" >/dev/null

    fi

    rm -f "$STATE"
}


# ============================================================
# SECOND PRESS ON SAME WINDOW -> RESTORE
# ============================================================

if [ -f "$STATE" ]; then

    OLD_ADDR="$(jq -r '.address' "$STATE")"

    if [ "$OLD_ADDR" = "$ADDR" ]; then
        restore_window
        exit 0
    fi

    # Another window was spotlighted before.
    # Restore it first.
    NEW_ADDR="$ADDR"

    restore_window

    # Return focus to the window user actually selected.
    hyprctl dispatch focuswindow \
        "address:$NEW_ADDR" >/dev/null 2>&1 || true

    ACTIVE="$(hyprctl activewindow -j)"
    ADDR="$(jq -r '.address // empty' <<< "$ACTIVE")"
fi


# ============================================================
# SAVE ORIGINAL STATE
# ============================================================

FLOATING="$(jq -r '.floating // false' <<< "$ACTIVE")"
PINNED="$(jq -r '.pinned // false' <<< "$ACTIVE")"

X="$(jq -r '.at[0] // 0' <<< "$ACTIVE")"
Y="$(jq -r '.at[1] // 0' <<< "$ACTIVE")"

W="$(jq -r '.size[0] // 1000' <<< "$ACTIVE")"
H="$(jq -r '.size[1] // 700' <<< "$ACTIVE")"


jq -n \
    --arg address "$ADDR" \
    --argjson floating "$FLOATING" \
    --argjson pinned "$PINNED" \
    --argjson x "$X" \
    --argjson y "$Y" \
    --argjson w "$W" \
    --argjson h "$H" \
    '{
        address: $address,
        floating: $floating,
        pinned: $pinned,
        x: $x,
        y: $y,
        w: $w,
        h: $h
    }' > "$STATE"


# ============================================================
# MAKE WINDOW FLOATING
# ============================================================

if [ "$FLOATING" != "true" ]; then
    hyprctl dispatch setfloating \
        "address:$ADDR" >/dev/null
fi


# ============================================================
# PIN WINDOW ACROSS WORKSPACES
# ============================================================

if [ "$PINNED" != "true" ]; then
    hyprctl dispatch pin active >/dev/null
fi


# ============================================================
# MACOS-LIKE CENTERED SIZE
# ============================================================

hyprctl dispatch resizeactive \
    "exact 1000 700" >/dev/null

hyprctl dispatch centerwindow 1 >/dev/null

