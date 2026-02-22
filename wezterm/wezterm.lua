local wezterm = require 'wezterm'
local nord = require 'colors/nord'

local act = wezterm.action

local config = {
  colors = nord.colors,
  background = {
    {
      source = { File = wezterm.home_dir .. '/Pictures/terminal.jpg' },
    },
  },
  window_background_opacity = 1.0,
  window_decorations = 'NONE',
  keys = {
    {key = '1', mods = 'ALT', action = act.ActivateTab(0)},
    {key = '2', mods = 'ALT', action = act.ActivateTab(1)},
    {key = '3', mods = 'ALT', action = act.ActivateTab(2)},
    {key = '4', mods = 'ALT', action = act.ActivateTab(3)},
    {key = '5', mods = 'ALT', action = act.ActivateTab(4)},
    {key = '6', mods = 'ALT', action = act.ActivateTab(5)},
    {key = '7', mods = 'ALT', action = act.ActivateTab(6)},
    {key = '8', mods = 'ALT', action = act.ActivateTab(7)},
    {key = '9', mods = 'ALT', action = act.ActivateTab(8)},
    {key = '0', mods = 'ALT', action = act.ActivateTab(-1)}, -- ALT+0 goes to last tab
  },
}

return config