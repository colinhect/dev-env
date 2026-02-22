#!/bin/bash
# Script to install and configure Oh My Zsh

set -e

echo "Installing Oh My Zsh..."

if ! command -v zsh &> /dev/null; then
    echo "Error: zsh is not installed. Run install-dependencies.sh first."
    exit 1
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh already installed, skipping..."
else
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    echo "Oh My Zsh installed successfully!"
fi

echo "Installing zsh-syntax-highlighting plugin..."
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    echo "zsh-syntax-highlighting installed successfully!"
else
    echo "zsh-syntax-highlighting already installed, skipping..."
fi

chsh -s $(which zsh)

echo ""
echo "Oh My Zsh setup complete!"
echo ""
echo "To use zsh as your default shell, run:"
echo "  chsh -s \$(which zsh)"
echo ""
echo "Or start zsh manually with: zsh"
