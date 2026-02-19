#!/bin/bash
# Script to install development dependencies on Fedora

set -e

echo "Installing development dependencies..."

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

# Update system first
echo "Updating system packages..."
$SUDO dnf update -y

# Install development tools
echo "Installing core development tools..."
$SUDO dnf groupinstall -y "Development Tools"

# Install specific packages
echo "Installing specific development packages..."
$SUDO dnf install -y \
    tmux \
    clang \
    gcc \
    gcc-c++ \
    make \
    cmake \
    git \
    python3 \
    python3-pip \
    python3-devel \
    nodejs \
    npm \
    ripgrep \
    fd-find \
    fzf \
    htop \
    tree \
    wget \
    curl \
    unzip \
    tar \
    gzip \
    xz

# Install tree-sitter CLI
echo "Installing tree-sitter CLI..."
$SUDO npm install -g tree-sitter-cli

# Install Python packages for Neovim
echo "Installing Python packages for Neovim..."
pip3 install --user pynvim

echo "All development dependencies installed successfully!"
echo ""
echo "Installed packages:"
echo "  - tmux"
echo "  - clang, gcc, g++"
echo "  - make, cmake"
echo "  - git"
echo "  - Python 3 + pip"
echo "  - Node.js + npm"
echo "  - ripgrep, fd-find, fzf"
echo "  - tree-sitter"
echo "  - Various utilities (htop, tree, wget, curl, etc.)"
