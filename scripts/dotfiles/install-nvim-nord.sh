#!/bin/bash
# Install Neovim nord colors

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../config.sh"

log_info "Installing Neovim nord colors..."

ensure_dir "$HOME/.local/share/nvim/site/pack/core/opt/nord.nvim/lua/nord"
copy_with_backup "$DOTFILES_DIR/.local/share/nvim/site/pack/core/opt/nord.nvim/lua/nord/named_colors.lua" \
    "$HOME/.local/share/nvim/site/pack/core/opt/nord.nvim/lua/nord/named_colors.lua"

log_info "Neovim nord colors installed"
