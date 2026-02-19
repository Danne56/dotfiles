-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Load Wezterm Action
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.color_scheme = 'coolnight'

-- Font settings
config.font = wezterm.font("JetBrainsMono NF")
config.font_size = 13.0
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"

-- UI preferences
config.enable_tab_bar = false
-- config.window_decorations = "RESIZE"
-- config.window_background_opacity = 0.9
-- config.prefer_egl = true

-- Custom mouse behavior
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ""
      if has_selection then
        window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.PasteFrom("Clipboard"), pane)
      end
    end),
  },
}

-- Key bindings
config.keys = {
  -- Toggle fullscreen
  {
    key = "n",
    mods = "CTRL|SHIFT",
    action = act.ToggleFullScreen,
  },

  { key = 'Enter',
  	mods = 'ALT',
  	action = wezterm.action.DisableDefaultAssignment
  },
  -- Split horizontally (bawah)
  {
    key = "d",
    mods = "CTRL|SHIFT",
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },

  -- Split vertically (kanan)
  {
    key = "f",
    mods = "CTRL|SHIFT",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },

  -- Navigate between panes
  { key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down") },

  -- Resize pane
  { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "UpArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 3 }) },
  { key = "DownArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 3 }) },
}

return config
