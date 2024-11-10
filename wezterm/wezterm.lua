-- Pull in the wezterm API
local wezterm = require("wezterm")
local theme = wezterm.plugin.require('https://github.com/neapsix/wezterm').main

-- This will hold the configuration
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback({"MonoLisa","MesloLGS Nerd Font Mono"})
config.font_size = 20 

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.macos_window_background_blur = 40 

config.colors = theme.colors()
config.window_frame = theme.window_frame()

return config
