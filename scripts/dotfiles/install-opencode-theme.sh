#!/bin/bash
# Install opencode theme

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../config.sh"

log_info "Installing opencode theme..."

ensure_dir "$HOME/.config/opencode/themes"
copy_with_backup "$DOTFILES_DIR/.config/opencode/themes/nord-custom.json" \
    "$HOME/.config/opencode/themes/nord-custom.json"

log_info "Opencode theme installed: ~/.config/opencode/themes/nord-custom.json"
