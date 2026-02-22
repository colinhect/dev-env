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

backup_dir_if_exists() {
    local dir="$1"
    if [ -d "$dir" ] && [ ! -L "$dir" ]; then
        echo "Backing up existing $dir to ${dir}.backup"
        mv "$dir" "${dir}.backup"
    fi
}

# Install .tmux.conf
echo "Installing .tmux.conf..."
backup_if_exists "$HOME/.tmux.conf"
cp "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Install .zshrc
echo "Installing .zshrc..."
backup_if_exists "$HOME/.zshrc"
cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Install Neovim configuration
echo "Installing Neovim configuration..."
mkdir -p "$HOME/.config/nvim"
backup_if_exists "$HOME/.config/nvim/init.lua"
cp "$DOTFILES_DIR/.config/nvim/init.lua" "$HOME/.config/nvim/init.lua"

# Install Wezterm configuration
echo "Installing Wezterm configuration..."
mkdir -p "$HOME/.config/wezterm"
backup_if_exists "$HOME/.config/wezterm/wezterm.lua"
cp "$DOTFILES_DIR/.config/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

# Install Wezterm colors
echo "Installing Wezterm colors..."
backup_dir_if_exists "$HOME/.config/wezterm/colors"
cp -r "$DOTFILES_DIR/.config/wezterm/colors" "$HOME/.config/wezterm/colors"

# Install Neovim nord colors
echo "Installing Neovim nord colors..."
mkdir -p "$HOME/.local/share/nvim/site/pack/core/opt/nord.nvim/lua/nord"
backup_if_exists "$HOME/.local/share/nvim/site/pack/core/opt/nord.nvim/lua/nord/named_colors.lua"
cp "$DOTFILES_DIR/.local/share/nvim/site/pack/core/opt/nord.nvim/lua/nord/named_colors.lua" \
   "$HOME/.local/share/nvim/site/pack/core/opt/nord.nvim/lua/nord/named_colors.lua"

# Install Opencode configuration
echo "Installing Opencode configuration..."
mkdir -p "$HOME/.config/opencode/themes"
backup_if_exists "$HOME/.config/opencode/opencode.json"
cp "$DOTFILES_DIR/.config/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
backup_if_exists "$HOME/.config/opencode/themes/nord-custom.json"
cp "$DOTFILES_DIR/.config/opencode/themes/nord-custom.json" "$HOME/.config/opencode/themes/nord-custom.json"

echo ""
echo "Dotfiles installed successfully!"
echo ""
echo "Installed files:"
echo "  - ~/.tmux.conf"
echo "  - ~/.zshrc"
echo "  - ~/.config/nvim/init.lua"
echo "  - ~/.config/wezterm/wezterm.lua"
echo "  - ~/.config/wezterm/colors/"
echo "  - ~/.local/share/nvim/site/pack/core/opt/nord.nvim/lua/nord/named_colors.lua"
echo "  - ~/.config/opencode/opencode.json"
echo "  - ~/.config/opencode/themes/nord-custom.json"
echo ""
