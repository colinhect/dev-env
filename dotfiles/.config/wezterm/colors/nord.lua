local wezterm = require 'wezterm'

return {
  colors = {
    foreground = "#DBDEE5",
    background = "#181818",

    cursor_bg = "#DBDEE5",
    cursor_fg = "#181818",
    cursor_border = "#DBDEE5",

    selection_fg = "#181818",
    selection_bg = "#6C717C",

    scrollbar_thumb = "#42444A",
    split = "#42444A",

    ansi = {
        "#181818", -- black
        "#B36C72", -- red
        "#A3B495", -- green
        "#E4C891", -- yellow
        "#6A829F", -- blue
        "#AA97A7", -- purple
        "#97B3B2", -- teal
        "#DBDEE5", -- darkest_white
    },
    brights = {
        "#6C717C", -- light_gray_bright
        "#B36C72", -- red (bright)
        "#A3B495", -- green (bright)
        "#E4C891", -- yellow (bright)
        "#90BBC7", -- off_blue
        "#AA97A7", -- purple (bright)
        "#8AA0B7", -- glacier
        "#EDEFF2", -- white
    },
  },
}
