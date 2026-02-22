#!/bin/bash

FONT_DIR="$HOME/.local/share/fonts"
ZIP_FILE="AdwaitaMono.zip"

mkdir -p "$FONT_DIR"

unzip -o "$ZIP_FILE" -d "$FONT_DIR"

fc-cache -fv "$FONT_DIR"

echo "AdwaitaMono font installed successfully."
