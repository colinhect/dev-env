#!/bin/bash
# Install Neovim configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../config.sh"

log_info "Installing Neovim configuration..."

ensure_dir "$HOME/.config/nvim"
copy_with_backup "$DOTFILES_DIR/.config/nvim/init.lua" "$HOME/.config/nvim/init.lua"

log_info "Neovim configuration installed: ~/.config/nvim/init.lua"
