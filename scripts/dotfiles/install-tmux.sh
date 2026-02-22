#!/bin/bash
# Install tmux configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../config.sh"

log_info "Installing tmux configuration..."

copy_with_backup "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

log_info "Tmux configuration installed: ~/.tmux.conf"
