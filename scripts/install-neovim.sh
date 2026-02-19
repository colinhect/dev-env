#!/bin/bash
# Script to install the latest Neovim development release

set -e

echo "Installing Neovim development release..."

# Check if running on Fedora/RHEL
if ! command -v dnf &> /dev/null; then
    echo "Error: This script is designed for Fedora/RHEL systems with dnf"
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "Downloading latest Neovim nightly release..."

# Download the latest nightly build
NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz"
curl -LO "$NVIM_URL"

echo "Extracting Neovim..."
tar xzf nvim-linux64.tar.gz

echo "Installing Neovim to /usr/local..."
sudo rm -rf /usr/local/nvim-linux64
sudo mv nvim-linux64 /usr/local/

# Create symlink
sudo ln -sf /usr/local/nvim-linux64/bin/nvim /usr/local/bin/nvim

# Clean up
cd -
rm -rf "$TEMP_DIR"

echo "Verifying installation..."
nvim --version

echo "Neovim nightly installed successfully!"
echo "You can run it with: nvim"
