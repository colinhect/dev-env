#!/bin/bash
# Install custom fonts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd")
source "$SCRIPT_DIR/../scripts/lib/common.sh"
source "$SCRIPT_DIR/../scripts/config.sh"

log_info "Installing custom fonts..."

require_command unzip "unzip is required. Run install-dependencies.sh first."

ensure_dir "$FONT_DIR"

FONT_ZIP="$SCRIPT_DIR/AdwaitaMono.zip"

if [ ! -f "$FONT_ZIP" ]; then
    log_error "Font zip not found: $FONT_ZIP"
    exit 1
fi

maybe_run unzip -o "$FONT_ZIP" -d "$FONT_DIR"

log_step "Updating font cache..."
maybe_run fc-cache -fv "$FONT_DIR"

log_info "AdwaitaMono font installed successfully!"
