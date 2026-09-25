-- AVE Hyprland Lua configuration.
-- Static appearance/rules live in settings.lua and rules.lua.
-- GUI-controlled settings are generated from settings.json.

require("config.variables")
require("config.settings")
require("config.rules")

require("config.generated_env")
require("config.generated_monitors")
require("config.generated_keybindings")
require("config.generated_autostart")

-- Keep the passthru submap expected by Quickshell.
hl.define_submap("passthru", function()
  hl.bind("SUPER + SHIFT + CTRL + ALT + F35", hl.dsp.exec_cmd("true"))
end)
