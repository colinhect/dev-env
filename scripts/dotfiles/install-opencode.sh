#!/bin/bash
# Install opencode configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../config.sh"

log_info "Installing opencode configuration..."

ensure_dir "$HOME/.config/opencode"
copy_with_backup "$DOTFILES_DIR/.config/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"

log_info "Opencode configuration installed: ~/.config/opencode/opencode.json"
