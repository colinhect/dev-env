#!/bin/bash
# Script to install the latest Neovim development release

set -e

echo "Installing Neovim development release..."

# Check if running on Fedora/RHEL
if ! command -v dnf &> /dev/null; then
    echo "Error: This script is designed for Fedora/RHEL systems with dnf"
    exit 1
fi

# Check for curl
if ! command -v curl &> /dev/null; then
    echo "Error: curl is required but not installed"
    exit 1
fi

# Store original directory
ORIG_DIR=$(pwd)

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "Downloading latest Neovim nightly release..."

# Download the latest nightly build
NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz"
if ! curl -fLO "$NVIM_URL"; then
    echo "Error: Failed to download Neovim from $NVIM_URL"
    exit 1
fi

echo "Extracting Neovim..."
if ! tar xzf nvim-linux-x86_64.tar.gz; then
    echo "Error: Failed to extract Neovim archive"
    exit 1
fi

echo "Installing Neovim to /usr/local..."
sudo rm -rf /usr/local/nvim-linux-x86_64
sudo mv nvim-linux-x86_64 /usr/local/

# Create symlink in user's local bin
mkdir -p "$HOME/.local/bin"
ln -sf /usr/local/nvim-linux-x86_64/bin/nvim "$HOME/.local/bin/nvim"

# Clean up
cd "$ORIG_DIR"
rm -rf "$TEMP_DIR"

echo "Verifying installation..."
if ! nvim --version; then
    echo "Error: Neovim installation verification failed"
    exit 1
fi

echo "Neovim nightly installed successfully!"
echo "You can run it with: nvim"
