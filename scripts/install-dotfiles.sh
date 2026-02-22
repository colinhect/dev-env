#!/bin/bash
# Script to install dotfiles to user's home directory
# Can install all dotfiles or specific components

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/config.sh"

DOTFILES_MODULE_DIR="$SCRIPT_DIR/dotfiles"

show_usage() {
    echo "Usage: $0 [OPTIONS] [COMPONENTS...]"
    echo ""
    echo "Install dotfiles to your home directory."
    echo ""
    echo "Components:"
    echo "  shell         .zshrc"
    echo "  tmux          .tmux.conf"
    echo "  nvim          Neovim init.lua"
    echo "  nvim-nord     Neovim nord colors"
    echo "  wezterm       Wezterm config"
    echo "  wezterm-colors Wezterm color schemes"
    echo "  opencode      Opencode config"
    echo "  opencode-theme Opencode theme"
    echo ""
    echo "Options:"
    echo "  -a, --all       Install all components (default)"
    echo "  -l, --list      List available components"
    echo "  -h, --help      Show this help message"
    echo "  --dry-run       Show what would be done without making changes"
    echo ""
    echo "Examples:"
    echo "  $0                    # Install all dotfiles"
    echo "  $0 shell tmux         # Install only shell and tmux configs"
    echo "  $0 --dry-run nvim     # Preview nvim config installation"
}

list_components() {
    echo "Available dotfile components:"
    echo ""
    for entry in "${DOTFILE_COMPONENTS[@]}"; do
        IFS=':' read -r name src dest <<< "$entry"
        printf "  %-15s %s\n" "$name" "$dest"
    done
}

install_component() {
    local component="$1"
    local script="$DOTFILES_MODULE_DIR/install-${component}.sh"
    
    if [ ! -f "$script" ]; then
        log_error "Unknown component: $component"
        return 1
    fi
    
    bash "$script"
}

parse_args() {
    INSTALL_ALL=true
    COMPONENTS=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--all)
                INSTALL_ALL=true
                shift
                ;;
            -l|--list)
                list_components
                exit 0
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                COMPONENTS+=("$1")
                INSTALL_ALL=false
                shift
                ;;
        esac
    done
}

parse_args "$@"

log_info "Installing dotfiles..."

if [ "$INSTALL_ALL" = true ]; then
    for entry in "${DOTFILE_COMPONENTS[@]}"; do
        IFS=':' read -r name src dest <<< "$entry"
        install_component "$name"
    done
else
    for component in "${COMPONENTS[@]}"; do
        install_component "$component"
    done
fi

log_info "Dotfiles installation complete!"
