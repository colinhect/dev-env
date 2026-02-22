#!/bin/bash
# Install Wezterm configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../config.sh"

log_info "Installing Wezterm configuration..."

ensure_dir "$HOME/.config/wezterm"
copy_with_backup "$DOTFILES_DIR/.config/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

log_info "Wezterm configuration installed: ~/.config/wezterm/wezterm.lua"
