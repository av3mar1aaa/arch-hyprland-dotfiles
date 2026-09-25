#!/usr/bin/env python3

import argparse
import json
import subprocess


parser = argparse.ArgumentParser()
parser.add_argument("--category", default="All")
parser.add_argument("--query", default="")
args = parser.parse_args()


def get_binds():
    try:
        raw = subprocess.check_output(
            ["hyprctl", "binds", "-j"],
            text=True
        )
        return json.loads(raw)
    except Exception:
        return []


def decode_mods(mask):
    mods = []

    mapping = [
        (64, "SUPER"),
        (4,  "CTRL"),
        (8,  "ALT"),
        (1,  "SHIFT"),
        (16, "MOD2"),
        (32, "MOD3"),
        (128, "MOD5"),
    ]

    for bit, name in mapping:
        if mask & bit:
            mods.append(name)

    return mods


def pretty_key(key):
    replacements = {
        "RETURN": "ENTER",
        "ESCAPE": "ESC",
        "mouse_down": "WHEEL ↓",
        "mouse_up": "WHEEL ↑",
        "XF86AudioRaiseVolume": "VOL +",
        "XF86AudioLowerVolume": "VOL -",
        "XF86AudioMute": "MUTE",
        "XF86AudioMicMute": "MIC MUTE",
        "XF86MonBrightnessUp": "BRIGHT +",
        "XF86MonBrightnessDown": "BRIGHT -",
        "XF86AudioPlay": "PLAY / PAUSE",
        "XF86AudioNext": "NEXT",
        "XF86AudioPrev": "PREVIOUS",
    }

    return replacements.get(key, key)


def category_for(dispatcher, arg, key):
    d = dispatcher.lower()
    a = arg.lower()
    k = key.lower()

    if (
        "xf86audio" in k
        or "xf86monbrightness" in k
        or "playerctl" in a
        or "wpctl" in a
        or "pamixer" in a
        or "brightnessctl" in a
        or "swayosd-client" in a
    ):
        return "Media"

    if d in (
        "workspace",
        "movetoworkspace",
        "movetoworkspacesilent",
        "swapactiveworkspaces",
    ):
        return "Workspaces"

    if (
        d in (
            "killactive",
            "togglefloating",
            "fullscreen",
            "pseudo",
            "movefocus",
            "movewindow",
            "resizeactive",
            "layoutmsg",
            "setfloating",
            "settiled",
            "centerwindow",
        )
    ):
        return "Windows"

    if (
        "hyprlock" in a
        or "lock.sh" in a
        or "systemctl" in a
        or "shutdown" in a
        or "reboot" in a
        or d == "exit"
        or "screenshot" in a
        or "controlcenter" in a
        or "settings" in a
        or "wallpaper" in a
    ):
        return "System"

    if d == "exec":
        return "Apps"

    return "System"


def pretty_action(dispatcher, arg):
    d = dispatcher.lower()
    a = arg.lower()

    if "kitty" in a and "edex" not in a:
        return "Terminal"

    if "edex-ui" in a:
        return "eDEX-UI"

    if "nautilus" in a:
        return "Files"

    if "dolphin" in a:
        return "Files"

    if "rofi -show drun" in a:
        return "App launcher"

    if "cliphist" in a:
        return "Clipboard"

    if "controlcenter" in a:
        return "Control Center"

    if "wallpaper" in a:
        return "Wallpaper picker"

    if "lock.sh" in a or "hyprlock" in a:
        return "Lock screen"

    if "screenshot-full" in a:
        return "Screenshot — full screen"

    if "screenshot-region" in a:
        return "Screenshot — region"

    if "playerctl" in a:
        if "next" in a:
            return "Next track"
        if "previous" in a:
            return "Previous track"
        return "Play / Pause"

    if "brightness" in a:
        if "+" in a or "inc" in a:
            return "Increase brightness"
        return "Change brightness"

    if "wpctl" in a or "pamixer" in a:
        if "mute" in a:
            return "Toggle mute"
        return "Change volume"

    if d == "workspace":
        return f"Switch workspace → {arg}"

    if d in ("movetoworkspace", "movetoworkspacesilent"):
        return f"Move window → workspace {arg}"

    if d == "movefocus":
        directions = {
            "l": "Focus left",
            "r": "Focus right",
            "u": "Focus up",
            "d": "Focus down",
        }
        return directions.get(arg, "Move focus")

    if d == "killactive":
        return "Close active window"

    if d == "togglefloating":
        return "Toggle floating"

    if d == "fullscreen":
        return "Toggle fullscreen"

    if d == "pseudo":
        return "Toggle pseudo tiling"

    if d == "layoutmsg":
        if "togglesplit" in a:
            return "Toggle split direction"
        return "Layout action"

    if d == "exit":
        return "Exit Hyprland"

    if d == "exec":
        short = arg.replace("$HOME", "~")
        return short[:70] if short else "Run command"

    if arg:
        return f"{dispatcher}: {arg}"

    return dispatcher


results = []

for b in get_binds():

    key = str(
        b.get("key")
        or (
            f"code:{b.get('keycode')}"
            if b.get("keycode")
            else ""
        )
    )

    if not key:
        continue

    dispatcher = str(b.get("dispatcher") or "")
    arg = str(b.get("arg") or "")

    mask = int(b.get("modmask") or 0)
    mods = decode_mods(mask)

    display_key = pretty_key(key)

    combo_parts = mods + [display_key]
    combo = " + ".join(combo_parts)

    category = category_for(
        dispatcher,
        arg,
        key
    )

    title = (
        str(b.get("description") or "").strip()
        or pretty_action(dispatcher, arg)
    )

    raw = (
        (dispatcher + " " + arg)
        .strip()
        .replace("$HOME", "~")
    )

    item = {
        "combo": combo,
        "title": title,
        "raw": raw,
        "category": category,
    }

    q = args.query.lower().strip()

    if args.category != "All":
        if category != args.category:
            continue

    if q:
        searchable = (
            combo + " "
            + title + " "
            + raw + " "
            + category
        ).lower()

        if q not in searchable:
            continue

    results.append(item)


order = {
    "Apps": 0,
    "Windows": 1,
    "Workspaces": 2,
    "System": 3,
    "Media": 4,
}

results.sort(
    key=lambda x: (
        order.get(x["category"], 99),
        x["combo"]
    )
)

print(
    json.dumps(
        results,
        ensure_ascii=False
    )
)
