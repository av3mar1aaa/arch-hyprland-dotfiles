local mainMod = _G.mainMod or "SUPER"

hl.define_submap("passthru", function()
  hl.bind("SUPER + SHIFT + CTRL + ALT + F35", hl.dsp.exec_cmd("true"))
end)

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("$HOME/.local/bin/edex-ui"))

hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("$HOME/.local/bin/close-workspace-windows"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + M", hl.dsp.exit())

hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("rofi -show drun"))

hl.bind(mainMod .. " + B", hl.dsp.exec_cmd([[cliphist list | rofi -dmenu -p "Clipboard" | cliphist decode | wl-copy]]))

hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/qs_manager.sh toggle wallpaper"))

hl.bind(mainMod .. " + PAGE_UP", hl.dsp.exec_cmd("$HOME/.local/bin/screenshot-full"))
hl.bind(mainMod .. " + PAGE_DOWN", hl.dsp.exec_cmd("$HOME/.local/bin/screenshot-region"))

hl.bind(mainMod .. " + LEFT", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + RIGHT", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + UP", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + DOWN", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + D", hl.dsp.focus({ workspace = "empty" }))

for i = 1, 10 do
  local key = tostring(i % 10)
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), { locked = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true, repeating = true })
