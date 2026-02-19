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

# Install .bashrc
echo "Installing .bashrc..."
backup_if_exists "$HOME/.bashrc"
cp "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"

# Install .bash_profile
echo "Installing .bash_profile..."
backup_if_exists "$HOME/.bash_profile"
cp "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"

# Install .tmux.conf
echo "Installing .tmux.conf..."
backup_if_exists "$HOME/.tmux.conf"
cp "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

echo ""
echo "Dotfiles installed successfully!"
echo ""
echo "Installed files:"
echo "  - ~/.bashrc"
echo "  - ~/.bash_profile"
echo "  - ~/.tmux.conf"
echo ""
echo "Run 'source ~/.bashrc' to apply bash changes in current shell"
