#!/usr/bin/env python3

import json
import subprocess


MODS = [
    (64, "SUPER"),
    (4,  "CTRL"),
    (8,  "ALT"),
    (1,  "SHIFT"),
]

KEY_NAMES = {
    "RETURN": "Enter",
    "SPACE": "Space",
    "TAB": "Tab",

    "LEFT": "←",
    "RIGHT": "→",
    "UP": "↑",
    "DOWN": "↓",

    "mouse:272": "LMB",
    "mouse:273": "RMB",
    "mouse:274": "MMB",

    "mouse_up": "Wheel ↑",
    "mouse_down": "Wheel ↓",

    "backslash": "\\",

    "XF86AudioRaiseVolume": "Volume +",
    "XF86AudioLowerVolume": "Volume −",
    "XF86AudioMute": "Mute",
    "XF86AudioMicMute": "Mic Mute",
    "XF86AudioPlay": "Play / Pause",
    "XF86AudioPause": "Play / Pause",
    "XF86AudioNext": "Next track",
    "XF86AudioPrev": "Previous track",

    "XF86MonBrightnessUp": "Brightness +",
    "XF86MonBrightnessDown": "Brightness −",
}


def pretty_key(key, code):
    if key:
        return KEY_NAMES.get(key, KEY_NAMES.get(key.upper(), key))

    if code:
        return f"code:{code}"

    return "?"


def combo(item):
    mask = int(item.get("modmask") or 0)

    result = []

    for bit, name in MODS:
        if mask & bit:
            result.append(name)

    key = pretty_key(
        str(item.get("key") or ""),
        item.get("keycode"),
    )

    result.append(key)

    return " + ".join(result)


def action(dispatcher, arg):
    d = (dispatcher or "").lower()
    a = (arg or "").strip()
    al = a.lower()

    if d == "killactive":
        return "Закрыть активное окно"

    if d == "togglefloating":
        return "Переключить tiled / floating"

    if d == "setfloating":
        return "Перевести окно в floating"

    if d == "settiled":
        return "Вернуть окно в сетку"

    if d == "fullscreen":
        return "Полноэкранный режим"

    if d == "pseudo":
        return "Псевдотайлинг"

    if d == "layoutmsg":
        if "togglesplit" in al:
            return "Сменить направление разделения"
        return "Управление раскладкой"

    if d == "movefocus":
        return {
            "l": "Фокус на окно слева",
            "r": "Фокус на окно справа",
            "u": "Фокус на окно сверху",
            "d": "Фокус на окно снизу",
        }.get(al, "Переместить фокус")

    if d == "movewindow":
        return {
            "l": "Переместить окно влево",
            "r": "Переместить окно вправо",
            "u": "Переместить окно вверх",
            "d": "Переместить окно вниз",
        }.get(al, "Свободно перемещать окно")

    if d == "resizewindow":
        return "Изменять размер окна"

    if d == "resizeactive":
        if a.startswith("-"):
            return "Уменьшить окно"
        return "Увеличить окно"

    if d == "workspace":
        if al == "empty":
            return "Перейти на свободный рабочий стол"

        if al == "e+1":
            return "Следующий рабочий стол"

        if al == "e-1":
            return "Предыдущий рабочий стол"

        return f"Рабочий стол {a}"

    if d == "movetoworkspace":
        return f"Переместить окно на рабочий стол {a}"

    if d == "exit":
        return "Выйти из Hyprland"

    if d == "exec":

        patterns = [
            ("toggle keybinds", "Показать список горячих клавиш"),

            ("toggle wallpaper", "Открыть выбор обоев"),
            ("toggle clipboard", "Открыть буфер обмена"),
            ("toggle calendar", "Открыть календарь"),
            ("toggle network", "Открыть сеть"),
            ("toggle volume", "Открыть микшер громкости"),
            ("toggle battery", "Открыть питание"),
            ("toggle music", "Открыть музыку"),
            ("toggle settings", "Открыть настройки"),
            ("toggle guide", "Открыть Guide"),
            ("toggle focustime", "Открыть FocusTime"),
            ("toggle movies", "Открыть Movies"),
            ("toggle applauncher", "Открыть меню приложений"),

            ("rofi -show drun", "Открыть меню приложений"),
            ("cliphist list", "Открыть историю буфера"),

            ("screenshot-full", "Скриншот всего экрана"),
            ("screenshot-region", "Скриншот области"),
            ("screenshot.sh --full", "Скриншот всего экрана"),
            ("screenshot.sh", "Сделать скриншот"),

            ("lock.sh", "Заблокировать компьютер"),

            ("playerctl play-pause", "Play / Pause"),
            ("playerctl next", "Следующий трек"),
            ("playerctl previous", "Предыдущий трек"),

            ("--output-volume raise", "Увеличить громкость"),
            ("--output-volume lower", "Уменьшить громкость"),
            ("--output-volume mute-toggle", "Mute"),
            ("--input-volume mute-toggle", "Mute микрофона"),

            ("--brightness raise", "Увеличить яркость"),
            ("--brightness lower", "Уменьшить яркость"),

            ("edex-ui", "Открыть eDEX-UI"),
            ("kitty", "Открыть Kitty"),
            ("dolphin", "Открыть Dolphin"),
            ("firefox", "Открыть Firefox"),
        ]

        for needle, title in patterns:
            if needle in al:
                return title

        short = a.replace(
            "/home/ave/",
            "~/"
        )

        if len(short) > 60:
            short = short[:57] + "..."

        return "Запустить: " + short

    return (dispatcher + " " + a).strip()


def category(dispatcher, arg):
    d = (dispatcher or "").lower()
    a = (arg or "").lower()

    if d in {
        "killactive",
        "togglefloating",
        "setfloating",
        "settiled",
        "fullscreen",
        "pseudo",
        "layoutmsg",
        "movefocus",
        "movewindow",
        "resizewindow",
        "resizeactive",
    }:
        return "Окна"

    if d in {
        "workspace",
        "movetoworkspace",
    }:
        return "Рабочие столы"

    if (
        "playerctl" in a
        or "swayosd" in a
        or "brightness" in a
    ):
        return "Медиа"

    if (
        "qs_manager" in a
        or "rofi" in a
        or "cliphist" in a
    ):
        return "Интерфейс"

    if (
        "screenshot" in a
        or "lock.sh" in a
        or d == "exit"
    ):
        return "Система"

    if d == "exec":
        return "Приложения"

    return "Другое"


try:
    raw = subprocess.check_output(
        ["hyprctl", "binds", "-j"],
        text=True
    )

    binds = json.loads(raw)

except Exception as e:
    print(json.dumps({
        "count": 0,
        "error": str(e),
        "items": []
    }, ensure_ascii=False))

    raise SystemExit


items = []
seen = set()

for b in binds:

    c = combo(b)

    dispatcher = str(
        b.get("dispatcher") or ""
    )

    arg = str(
        b.get("arg") or ""
    )

    identity = (
        c,
        dispatcher,
        arg,
    )

    if identity in seen:
        continue

    seen.add(identity)

    items.append({
        "combo": c,
        "action": action(dispatcher, arg),
        "category": category(dispatcher, arg),
    })


order = {
    "Окна": 0,
    "Приложения": 1,
    "Рабочие столы": 2,
    "Интерфейс": 3,
    "Система": 4,
    "Медиа": 5,
    "Другое": 6,
}

items.sort(
    key=lambda x: (
        order.get(x["category"], 99),
        x["combo"]
    )
)

print(json.dumps({
    "count": len(items),
    "items": items
}, ensure_ascii=False))
