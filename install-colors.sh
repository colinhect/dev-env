#!/bin/bash

SOURCE="$(dirname "$0")/named_colors.lua"
DEST="$HOME/.local/share/nvim/site/pack/core/opt/nord.nvim/lua/nord/named_colors.lua"

mkdir -p "$(dirname "$DEST")"
cp "$SOURCE" "$DEST"
echo "Installed named_colors.lua to $DEST"
