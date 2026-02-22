local wezterm = require 'wezterm'
local nord = require 'colors/nord'

return {
  font = wezterm.font 'AdwaitaMono Nerd Font',
  colors = nord.colors,
  background = {
    {
      source = { File = wezterm.home_dir .. '/Pictures/terminal.jpg' },
    },
  },
  window_background_opacity = 1.0,
}
