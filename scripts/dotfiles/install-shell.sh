#!/bin/bash
# Install shell configuration (.zshrc)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../config.sh"

log_info "Installing shell configuration..."

copy_with_backup "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

log_info "Shell configuration installed: ~/.zshrc"
