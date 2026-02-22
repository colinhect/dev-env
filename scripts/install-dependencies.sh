#!/bin/bash
# Script to install development dependencies on Fedora

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/config.sh"

log_info "Installing development dependencies..."

if ! is_fedora; then
    log_error "This script is designed for Fedora/RHEL systems with dnf"
    exit 1
fi

SUDO=$(get_sudo)

log_step "Updating system packages..."
maybe_run $SUDO dnf update -y

log_step "Installing development tools group..."
maybe_run $SUDO dnf group install -y development-tools

log_step "Installing packages: ${ALL_PACKAGES[*]}"
maybe_run $SUDO dnf install -y "${ALL_PACKAGES[@]}"

log_step "Installing NPM global packages: ${NPM_GLOBAL_PACKAGES[*]}"
maybe_run $SUDO npm install -g "${NPM_GLOBAL_PACKAGES[@]}"

log_step "Installing lazygit..."
if ! command_exists lazygit; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    TEMP_DIR=$(create_temp_dir)
    download_file "${LAZYGIT_URL_BASE}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" "$TEMP_DIR/lazygit.tar.gz"
    maybe_run $SUDO tar xf "$TEMP_DIR/lazygit.tar.gz" -C /usr/local/bin lazygit
    cleanup_temp "$TEMP_DIR"
else
    log_info "lazygit already installed, skipping..."
fi

log_step "Installing Python packages: ${PYTHON_PACKAGES[*]}"
maybe_run pip3 install "${PYTHON_PACKAGES[@]}"

log_info "All development dependencies installed successfully!"
