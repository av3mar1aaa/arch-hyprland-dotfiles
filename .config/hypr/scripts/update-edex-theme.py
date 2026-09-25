#!/usr/bin/env python3

from pathlib import Path
import json

home = Path.home()

palette_path = (
    home /
    ".config/hypr/scripts/quickshell/qs_colors.json"
)

theme_path = (
    home /
    ".config/eDEX-UI/themes/ave-hypr.json"
)

if not palette_path.exists():
    raise SystemExit("Matugen palette not found")


with palette_path.open() as f:
    p = json.load(f)


# ------------------------------------------------------------
# Color helpers
# ------------------------------------------------------------

def hex_to_rgb(value):
    value = value.lstrip("#")
    return tuple(
        int(value[i:i+2], 16)
        for i in (0, 2, 4)
    )


def rgb_to_hex(rgb):
    return "#%02x%02x%02x" % tuple(
        max(0, min(255, round(x)))
        for x in rgb
    )


def mix(color1, color2, amount):
    a = hex_to_rgb(color1)
    b = hex_to_rgb(color2)

    return rgb_to_hex(
        tuple(
            x * (1 - amount) + y * amount
            for x, y in zip(a, b)
        )
    )


def rgba(hex_color, alpha):
    r, g, b = hex_to_rgb(hex_color)
    return f"rgba({r},{g},{b},{alpha})"


# ------------------------------------------------------------
# Matugen palette
# ------------------------------------------------------------

base      = p.get("base", "#090f0e")
mantle    = p.get("mantle", "#171d1b")
surface0  = p.get("surface0", "#1b211f")
surface1  = p.get("surface1", "#252b29")

text      = p.get("text", "#dee4e1")
subtext   = p.get("subtext0", "#bec9c5")

primary   = p.get("blue", "#83d5c4")
secondary = p.get("teal", "#b1ccc5")
tertiary  = p.get("peach", "#abcae4")

red       = p.get("red", "#ffb4ab")
green     = p.get("green", secondary)

# Make secondary terminal colours readable even when
# Matugen container colours are very dark.
yellow    = tertiary
magenta   = mix(primary, tertiary, 0.45)
cyan      = mix(primary, secondary, 0.35)

white     = text
grey      = surface1

lightBlack   = mix(surface1, text, 0.25)
lightRed     = mix(red, text, 0.20)
lightGreen   = mix(green, text, 0.20)
lightYellow  = mix(yellow, text, 0.20)
lightBlue    = mix(primary, text, 0.18)
lightMagenta = mix(magenta, text, 0.20)
lightCyan    = mix(cyan, text, 0.20)
lightWhite   = mix(text, "#ffffff", 0.25)

r, g, b = hex_to_rgb(primary)


# ------------------------------------------------------------
# Preserve your original eDEX structure
# ------------------------------------------------------------

theme = {
    "colors": {
        "r": r,
        "g": g,
        "b": b,

        "black": base,
        "red": red,
        "green": green,
        "yellow": yellow,
        "blue": primary,
        "magenta": magenta,
        "cyan": cyan,
        "white": white,

        "lightBlack": lightBlack,
        "lightRed": lightRed,
        "lightGreen": lightGreen,
        "lightYellow": lightYellow,
        "lightBlue": lightBlue,
        "lightMagenta": lightMagenta,
        "lightCyan": lightCyan,
        "lightWhite": lightWhite,

        "light_black": mantle,
        "grey": grey
    },

    "cssvars": {
        "font_main": "United Sans Medium",
        "font_main_light": "United Sans Light"
    },

    "terminal": {
        "fontFamily": "Fira Code",
        "fontSize": 15,
        "fontWeight": "normal",
        "fontWeightBold": "bold",
        "letterSpacing": 0,
        "lineHeight": 1.1,

        "cursorStyle": "bar",
        "cursorBlink": True,

        "foreground": text,
        "background": rgba(base, 0.94),

        "cursor": primary,
        "cursorAccent": base,

        "selection": rgba(primary, 0.25),

        "allowTransparency": True
    },

    "globe": {
        "base": base,
        "marker": text,
        "pin": primary,
        "satellite": secondary
    },

    "injectCSS":
        "body { "
        "background: radial-gradient("
        "circle at center, "
        f"{rgba(surface0, 0.98)} 0%, "
        f"{rgba(base, 0.99)} 72%"
        ") !important; "
        "} "

        "#main_shell { "
        f"text-shadow: 0 0 5px {rgba(primary, 0.18)}; "
        "} "

        ".mod_column, .mod_column_inner { "
        f"border-color: {rgba(primary, 0.48)} !important; "
        "} "

        "::-webkit-scrollbar-thumb { "
        f"background: {rgba(primary, 0.38)} !important; "
        "}"
}


with theme_path.open("w") as f:
    json.dump(
        theme,
        f,
        ensure_ascii=False,
        indent=4
    )

    f.write("\n")


print(
    f"eDEX theme: {base} / {primary} / {secondary}"
)
