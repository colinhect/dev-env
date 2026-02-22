#!/bin/bash
# Centralized configuration for dev-env

# Root directory of dev-env (computed from this file's location)
DEV_ENV_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="$DEV_ENV_ROOT/dotfiles"

# Local bin directory for user installations
LOCAL_BIN="$HOME/.local/bin"

# System packages to install (Fedora/dnf)
CORE_PACKAGES=(
    tmux
    zsh
    git
    curl
    wget
    unzip
    tar
    gzip
    xz
    python3
    python3-pip
    python3-devel
    nodejs
    npm
)

DEV_PACKAGES=(
    clang
    clang-tools-extra
    gcc
    gcc-c++
    make
    cmake
    gdb
    ripgrep
    fd-find
    fzf
    htop
    tree
    bat
    tldr
    golang
    rust
    cargo
    git-delta
)

ALL_PACKAGES=("${CORE_PACKAGES[@]}" "${DEV_PACKAGES[@]}")

# NPM global packages
NPM_GLOBAL_PACKAGES=(
    tree-sitter-cli
    pyright
)

# Python packages
PYTHON_PACKAGES=(
    toad
)

# URLs for downloads
NVIM_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz"
NVIM_INSTALL_DIR="/usr/local/nvim-linux-x86_64"

OPENCODE_URL_BASE="https://github.com/opencode-ai/opencode/releases/latest/download"

LAZYGIT_URL_BASE="https://github.com/jesseduffield/lazygit/releases/latest/download"

OHMYZSH_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

# Oh My Zsh plugins
OHMYZSH_PLUGINS=(
    "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions.git"
    "zsh-completions:https://github.com/zsh-users/zsh-completions.git"
)

# Dotfile components
DOTFILE_COMPONENTS=(
    "shell:.zshrc:$HOME/.zshrc"
    "tmux:.tmux.conf:$HOME/.tmux.conf"
    "nvim:.config/nvim/init.lua:$HOME/.config/nvim/init.lua"
    "wezterm:.config/wezterm/wezterm.lua:$HOME/.config/wezterm/wezterm.lua"
    "wezterm-colors:.config/wezterm/colors:$HOME/.config/wezterm/colors"
    "nvim-nord:.local/share/nvim/site/pack/core/opt/nord.nvim/lua/nord/named_colors.lua:$HOME/.local/share/nvim/site/pack/core/opt/nord.nvim/lua/nord/named_colors.lua"
    "opencode:.config/opencode/opencode.json:$HOME/.config/opencode/opencode.json"
    "opencode-theme:.config/opencode/themes/nord-custom.json:$HOME/.config/opencode/themes/nord-custom.json"
)

# Font installation
FONT_DIR="$HOME/.local/share/fonts"
