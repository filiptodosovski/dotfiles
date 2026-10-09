local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

local is_macos = wezterm.target_triple:find("apple", 1, true) ~= nil
-- Include user fonts even when they haven't been registered with the OS yet.
config.font_dirs = is_macos and { wezterm.home_dir .. "/Library/Fonts" }
  or {
    (os.getenv("XDG_DATA_HOME") or wezterm.home_dir .. "/.local/share") .. "/fonts",
    wezterm.home_dir .. "/.fonts",
  }
config.font = wezterm.font_with_fallback({
  { family = "MonoLisa", weight = "Regular" },
  { family = "MesloLGS Nerd Font Mono", weight = "Regular" },
})
config.font_size = 20

config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
if is_macos then
  config.macos_window_background_blur = 40
end

config.color_scheme = "rose-pine"

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1200 }

config.keys = {
  {
    key = "|",
    mods = "LEADER|SHIFT",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
  { key = "y", mods = "LEADER", action = act.CopyTo("Clipboard") },
}
if is_macos then
  table.insert(
    config.keys,
    { key = " ", mods = "CMD", action = act.SendKey({ key = "Space", mods = "CTRL" }) }
  )
end

config.key_tables = {
  copy_mode = {
    { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
    { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
    { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    {
      key = "y",
      mods = "NONE",
      action = act.Multiple({ act.CopyTo("ClipboardAndPrimarySelection"), act.CopyMode("Close") }),
    },
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
  },
}

return config
