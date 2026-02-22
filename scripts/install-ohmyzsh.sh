#!/bin/bash
# Script to install and configure Oh My Zsh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/config.sh"

log_info "Installing Oh My Zsh..."

require_command zsh "zsh is not installed. Run install-dependencies.sh first."

if [ -d "$HOME/.oh-my-zsh" ]; then
    log_info "Oh My Zsh already installed, skipping..."
else
    log_step "Installing Oh My Zsh..."
    maybe_run sh -c "$(curl -fsSL $OHMYZSH_INSTALL_URL)" "" --unattended
fi

for plugin_entry in "${OHMYZSH_PLUGINS[@]}"; do
    IFS=':' read -r plugin_name plugin_url <<< "$plugin_entry"
    plugin_path="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
    
    log_step "Installing $plugin_name plugin..."
    if [ ! -d "$plugin_path" ]; then
        maybe_run git clone "$plugin_url" "$plugin_path"
    else
        log_info "$plugin_name already installed, skipping..."
    fi
done

log_step "Setting zsh as default shell..."
if [ "$DRY_RUN" != "true" ]; then
    chsh -s "$(which zsh)"
fi

log_info "Oh My Zsh setup complete!"
log_info "Open a new terminal or run: zsh"
