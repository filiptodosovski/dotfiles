local wezterm = require("wezterm")
local theme = wezterm.plugin.require("https://github.com/neapsix/wezterm").main
local act = wezterm.action

local config = wezterm.config_builder()

-- MonoLisa is installed in the user font directory but is not registered with
-- CoreText on every launch, so make it discoverable to WezTerm explicitly.
config.font_dirs = { wezterm.home_dir .. "/Library/Fonts" }
config.font = wezterm.font_with_fallback({
  { family = "MonoLisa", weight = "Regular" },
  { family = "MesloLGS Nerd Font Mono", weight = "Regular" },
})
config.font_size = 20

config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.macos_window_background_blur = 40

config.colors = theme.colors()
config.window_frame = theme.window_frame()

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1200 }

config.keys = {
  { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
  { key = "y", mods = "LEADER", action = act.CopyTo("Clipboard") },
  { key = " ", mods = "CMD", action = act.SendKey({ key = "Space", mods = "CTRL" }) },
}

config.key_tables = {
  copy_mode = {
    { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
    { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
    { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "y", mods = "NONE", action = act.Multiple({ act.CopyTo("ClipboardAndPrimarySelection"), act.CopyMode("Close") }) },
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
  },
}

return config
