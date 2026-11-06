-- Exercise the macOS/Linux appearance without opening a GUI.
local root = assert(os.getenv("DOTFILES_DIR"), "DOTFILES_DIR is missing")
local mac_colors
for _, case in ipairs({
  { platform = "aarch64-apple-darwin" },
  { platform = "x86_64-unknown-linux-gnu" },
}) do
  local platform = case.platform
  local wezterm = {
    target_triple = platform,
    home_dir = "/test/home",
    config_builder = function()
      return {}
    end,
    font_with_fallback = function(fonts)
      return fonts
    end,
    action = setmetatable({}, {
      __index = function(_, name)
        return function(value)
          return { name = name, value = value }
        end
      end,
    }),
  }
  package.loaded.wezterm = wezterm
  local config = dofile(root .. "/wezterm/wezterm.lua")
  assert(config.font[1].family == "MonoLisa")
  assert(config.enable_tab_bar == false)
  local colors = config.color_schemes[config.color_scheme]
  if platform:find("apple", 1, true) then
    mac_colors = colors
  end
  for _, key in ipairs({ "foreground", "background", "cursor_bg", "selection_bg" }) do
    assert(colors[key] == mac_colors[key], key .. " differs from the Mac palette")
  end
  for _, key in ipairs({ "ansi", "brights" }) do
    for index, value in ipairs(mac_colors[key]) do
      assert(colors[key][index] == value, key .. " differs from the Mac palette")
    end
  end
  local quit
  for _, binding in ipairs(config.keys) do
    if binding.key == "q" and binding.mods == "CTRL" then
      quit = binding.action
    end
  end
  assert(#config.font_dirs > 0)
  assert(config.window_background_opacity == 0.92)
  assert(config.window_decorations == "RESIZE")
  assert(quit == nil)
  print("WezTerm config OK: " .. platform)
end
