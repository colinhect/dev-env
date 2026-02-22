#!/bin/bash
# Script to install the latest Neovim development release

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/config.sh"

log_info "Installing Neovim development release..."

require_command curl "curl is required. Run install-dependencies.sh first."

ORIG_DIR=$(pwd)
TEMP_DIR=$(create_temp_dir)

log_step "Downloading Neovim nightly..."
cd "$TEMP_DIR"

if ! download_file "$NVIM_URL" "nvim.tar.gz"; then
    log_error "Failed to download Neovim"
    cleanup_temp "$TEMP_DIR"
    exit 1
fi

log_step "Extracting Neovim..."
maybe_run tar xzf nvim.tar.gz

log_step "Installing Neovim to /usr/local..."
SUDO=$(get_sudo)
maybe_run $SUDO rm -rf "$NVIM_INSTALL_DIR"
maybe_run $SUDO mv nvim-linux-x86_64 /usr/local/

ensure_dir "$LOCAL_BIN"
maybe_run ln -sf "$NVIM_INSTALL_DIR/bin/nvim" "$LOCAL_BIN/nvim"

cd "$ORIG_DIR"
cleanup_temp "$TEMP_DIR"

log_step "Verifying installation..."
if [ "$DRY_RUN" != "true" ]; then
    if ! nvim --version; then
        log_error "Neovim installation verification failed"
        exit 1
    fi
fi

log_info "Neovim nightly installed successfully!"
log_info "You can run it with: nvim"
