#!/bin/bash
# Install Wezterm colors

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../config.sh"

log_info "Installing Wezterm colors..."

copy_dir_with_backup "$DOTFILES_DIR/.config/wezterm/colors" "$HOME/.config/wezterm/colors"

log_info "Wezterm colors installed: ~/.config/wezterm/colors/"
