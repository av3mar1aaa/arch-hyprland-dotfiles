#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/caching.sh"
qs_ensure_cache "wallpaper_picker"

FLAG="$QS_STATE_WALLPAPER_PICKER/wallpaper_initialized"
CACHE_IMG="$QS_CACHE_WALLPAPER_PICKER/current_wallpaper.png"

RELOAD_SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")/quickshell/wallpaper/matugen_reload.sh"

# If a cached wallpaper exists, restore the last selected wallpaper.
# This makes the wallpaper survive logout/reboot until another one is selected.
if [ -f "$CACHE_IMG" ]; then
    # Wait briefly for the awww daemon to become available.
    for _ in {1..50}; do
        awww query >/dev/null 2>&1 && break
        sleep 0.1
    done

    awww img "$CACHE_IMG" \
        --transition-type any \
        --transition-pos 0.5,0.5 \
        --transition-fps 144 \
        --transition-duration 1 &

    matugen image "$CACHE_IMG" --source-color-index 0

    if [ -f "$RELOAD_SCRIPT_PATH" ]; then
        chmod +x "$RELOAD_SCRIPT_PATH"
        bash "$RELOAD_SCRIPT_PATH"
    fi

    mkdir -p "$(dirname "$FLAG")"
    touch "$FLAG"

    exit 0
fi

# If no wallpaper dir is set, default to a common one to prevent find from failing
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"

sleep 0.5

# Find a random file
file=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) 2>/dev/null | shuf -n 1)

if [ -n "$file" ]; then
    # Copy to our persistent cache location instead of /tmp
    cp "$file" "$CACHE_IMG"
    
    awww img "$file" --transition-type any --transition-pos 0.5,0.5 --transition-fps 144 --transition-duration 1 &
    
    matugen image "$file" --source-color-index 0
    
    # Execute reload script if it exists
    if [ -f "$RELOAD_SCRIPT_PATH" ]; then
        chmod +x "$RELOAD_SCRIPT_PATH"
        bash "$RELOAD_SCRIPT_PATH"
    fi
fi

mkdir -p "$(dirname "$FLAG")"
touch "$FLAG"
