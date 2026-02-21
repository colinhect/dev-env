#!/bin/bash
# Script to install opencode CLI

set -e

echo "Installing opencode..."

if command -v opencode &> /dev/null; then
    echo "opencode already installed, skipping..."
    exit 0
fi

if ! command -v curl &> /dev/null; then
    echo "Error: curl is required but not installed"
    exit 1
fi

echo "Detecting system architecture..."
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        BINARY_ARCH="x86_64"
        ;;
    aarch64|arm64)
        BINARY_ARCH="aarch64"
        ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Downloading opencode for $BINARY_ARCH..."
OPENCODE_URL="https://github.com/opencode-ai/opencode/releases/latest/download/opencode-linux-${BINARY_ARCH}"

TEMP_DIR=$(mktemp -d)
curl -fLo "$TEMP_DIR/opencode" "$OPENCODE_URL"

echo "Installing opencode to /usr/local/bin..."
sudo install -m 755 "$TEMP_DIR/opencode" /usr/local/bin/opencode

rm -rf "$TEMP_DIR"

echo "Verifying installation..."
opencode --version

echo ""
echo "opencode installed successfully!"
echo "Run it with: opencode"
