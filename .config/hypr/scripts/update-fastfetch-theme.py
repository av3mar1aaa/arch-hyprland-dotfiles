#!/usr/bin/env python3

from pathlib import Path
import json
import re

home = Path.home()

palette_file = (
    home
    / ".config/hypr/scripts/quickshell/qs_colors.json"
)

fastfetch_file = (
    home
    / ".config/fastfetch/config.jsonc"
)

if not palette_file.exists() or not fastfetch_file.exists():
    raise SystemExit(0)


with palette_file.open() as f:
    p = json.load(f)

with fastfetch_file.open() as f:
    cfg = json.load(f)


primary   = p.get("blue",    "#89b4fa")
secondary = p.get("teal",    "#94e2d5")
tertiary  = p.get("peach",   "#fab387")

text      = p.get("text",     "#cdd6f4")
subtext   = p.get("subtext0", "#a6adc8")
outline   = p.get("subtext1", "#bac2de")

success   = p.get("green", "#a6e3a1")


# ------------------------------------------------------------
# Logo
# ------------------------------------------------------------

cfg.setdefault("logo", {})
cfg["logo"]["color"] = {
    "1": primary,
    "2": secondary,
    "3": tertiary
}


# ------------------------------------------------------------
# Main text palette
# ------------------------------------------------------------

cfg.setdefault("display", {})
cfg["display"]["color"] = {
    "keys": primary,
    "title": secondary,
    "output": text,
    "separator": outline
}


# ------------------------------------------------------------
# Convert HEX -> truecolor ANSI
# ------------------------------------------------------------

def ansi(hex_color):
    h = hex_color.lstrip("#")

    if len(h) != 6:
        return ""

    r = int(h[0:2], 16)
    g = int(h[2:4], 16)
    b = int(h[4:6], 16)

    return f"\x1b[38;2;{r};{g};{b}m"


ansi_re = re.compile(r"\x1b\[[0-9;]*m")


# ------------------------------------------------------------
# Preserve your ARCH SECURITY TERMINAL design,
# but recolor its lines from current wallpaper.
# ------------------------------------------------------------

for module in cfg.get("modules", []):

    if module.get("type") != "custom":
        continue

    value = module.get("format", "")

    # Remove old hardcoded ANSI color
    clean = ansi_re.sub("", value)

    if "ACCESS GRANTED" in clean:
        color = success

    elif (
        "SYSTEM CORE" in clean
        or "HARDWARE MATRIX" in clean
        or "SOFTWARE LOADOUT" in clean
    ):
        color = secondary

    elif (
        "ARCH SECURITY TERMINAL" in clean
        or clean.startswith("╭")
        or clean.startswith("╰")
    ):
        color = primary

    else:
        color = secondary

    module["format"] = (
        ansi(color)
        + clean
        + "\x1b[0m"
    )


with fastfetch_file.open("w") as f:
    json.dump(
        cfg,
        f,
        indent=2,
        ensure_ascii=False
    )

    f.write("\n")
