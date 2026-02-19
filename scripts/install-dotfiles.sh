#!/bin/bash
# Script to install dotfiles to user's home directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")/dotfiles"

echo "Installing dotfiles..."

# Backup existing dotfiles
backup_if_exists() {
    local file="$1"
    if [ -f "$file" ] || [ -L "$file" ]; then
        echo "Backing up existing $file to ${file}.backup"
        mv "$file" "${file}.backup"
    fi
}

# Install .tmux.conf
echo "Installing .tmux.conf..."
backup_if_exists "$HOME/.tmux.conf"
cp "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Install Neovim configuration
echo "Installing Neovim configuration..."
mkdir -p "$HOME/.config/nvim"
backup_if_exists "$HOME/.config/nvim/init.lua"
cp "$DOTFILES_DIR/.config/nvim/init.lua" "$HOME/.config/nvim/init.lua"

echo ""
echo "Dotfiles installed successfully!"
echo ""
echo "Installed files:"
echo "  - ~/.tmux.conf"
echo "  - ~/.config/nvim/init.lua"
echo ""
echo "Run 'source ~/.bashrc' to apply bash changes in current shell"
