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
$SUDO dnf group install development-tools

# Install specific packages
echo "Installing specific development packages..."
$SUDO dnf install -y \
    tmux \
    zsh \
    clang \
    clang-tools-extra \
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
    xz \
    gdb \
    bat \
    tldr \
    golang \
    rust \
    cargo \
    git-delta

# Install tree-sitter CLI
echo "Installing tree-sitter CLI..."
$SUDO npm install -g tree-sitter-cli

# Install pyright for Python LSP
echo "Installing pyright..."
$SUDO npm install -g pyright

# Install lazygit
echo "Installing lazygit..."
if ! command -v lazygit &> /dev/null; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    $SUDO tar xf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit
    rm /tmp/lazygit.tar.gz
else
    echo "lazygit already installed, skipping..."
fi

echo "Installing Python packages..."
pip3 install toad
#if [ "$EUID" -eq 0 ]; then
    #pip3 install pynvim
#else
    #pip3 install --user pynvim
#fi

echo "All development dependencies installed successfully!"
