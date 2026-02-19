#!/bin/bash
# Main setup script for development environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Development Environment Setup"
echo "=========================================="
echo ""

# Parse command line arguments
SKIP_DEPS=false
SKIP_NEOVIM=false
SKIP_DOTFILES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        --skip-neovim)
            SKIP_NEOVIM=true
            shift
            ;;
        --skip-dotfiles)
            SKIP_DOTFILES=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-deps       Skip installation of dependencies"
            echo "  --skip-neovim     Skip installation of Neovim"
            echo "  --skip-dotfiles   Skip installation of dotfiles"
            echo "  --help            Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Install dependencies
if [ "$SKIP_DEPS" = false ]; then
    echo "Step 1: Installing dependencies..."
    bash "$SCRIPT_DIR/install-dependencies.sh"
    echo ""
else
    echo "Step 1: Skipping dependencies installation"
    echo ""
fi

# Install Neovim
if [ "$SKIP_NEOVIM" = false ]; then
    echo "Step 2: Installing Neovim..."
    bash "$SCRIPT_DIR/install-neovim.sh"
    echo ""
else
    echo "Step 2: Skipping Neovim installation"
    echo ""
fi

# Install dotfiles
if [ "$SKIP_DOTFILES" = false ]; then
    echo "Step 3: Installing dotfiles..."
    bash "$SCRIPT_DIR/install-dotfiles.sh"
    echo ""
else
    echo "Step 3: Skipping dotfiles installation"
    echo ""
fi

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Your development environment is now configured."
echo ""
echo "Next steps:"
echo "  1. Open a new terminal or run: source ~/.bashrc"
echo "  2. Start using tmux: tmux"
echo "  3. Start using Neovim: nvim"
echo ""
