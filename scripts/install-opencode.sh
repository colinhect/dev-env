#!/bin/bash
# Script to install opencode CLI

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/config.sh"

log_info "Installing opencode..."

if command_exists opencode; then
    log_info "opencode already installed, skipping..."
    exit 0
fi

require_command curl "curl is required. Run install-dependencies.sh first."

ARCH=$(get_arch)
OPENCODE_URL="${OPENCODE_URL_BASE}/opencode-linux-${ARCH}"

log_step "Detecting system architecture: $ARCH"

TEMP_DIR=$(create_temp_dir)

log_step "Downloading opencode..."
if ! download_file "$OPENCODE_URL" "$TEMP_DIR/opencode"; then
    log_error "Failed to download opencode"
    cleanup_temp "$TEMP_DIR"
    exit 1
fi

log_step "Installing opencode to /usr/local/bin..."
SUDO=$(get_sudo)
maybe_run $SUDO install -m 755 "$TEMP_DIR/opencode" /usr/local/bin/opencode

cleanup_temp "$TEMP_DIR"

log_step "Verifying installation..."
if [ "$DRY_RUN" != "true" ]; then
    opencode --version
fi

log_info "opencode installed successfully!"
log_info "Run it with: opencode"
