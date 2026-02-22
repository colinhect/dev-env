#!/bin/bash

SOURCE="$(dirname "$0")/wezterm"
DEST="$HOME/.config/wezterm"

mkdir -p "$DEST"
cp -r "$SOURCE"/* "$DEST/"
echo "Installed wezterm config to $DEST"
