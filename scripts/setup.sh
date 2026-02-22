#!/bin/bash
# Main setup script for development environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/config.sh"

# Component registry: name|script|description|check_command
declare -A COMPONENTS=(
    [deps]="install-dependencies.sh|Install system dependencies|dnf --version"
    [neovim]="install-neovim.sh|Install Neovim nightly|nvim --version"
    [dotfiles]="install-dotfiles.sh|Install dotfiles|test -f \$HOME/.zshrc"
    [ohmyzsh]="install-ohmyzsh.sh|Install Oh My Zsh|test -d \$HOME/.oh-my-zsh"
    [opencode]="install-opencode.sh|Install opencode CLI|opencode --version"
    [fonts]="../fonts/install.sh|Install custom fonts|test -d \$FONT_DIR"
)

# Component dependencies
declare -A COMPONENT_DEPS=(
    [ohmyzsh]="deps"
    [neovim]="deps"
    [opencode]="deps"
)

DRY_RUN=false
CHECK_MODE=false
COMPONENTS_TO_RUN=()
COMPONENTS_TO_SKIP=()

show_usage() {
    echo "Usage: $0 [OPTIONS] [COMPONENTS...]"
    echo ""
    echo "Development environment setup script."
    echo ""
    echo "Components:"
    for name in deps neovim dotfiles ohmyzsh opencode fonts; do
        local desc="${COMPONENTS[$name]##*|}"
        printf "  %-12s %s\n" "$name" "$desc"
    done
    echo ""
    echo "Options:"
    echo "  -a, --all           Run all components (default)"
    echo "  -c, --check         Check what's installed without making changes"
    echo "  -d, --dry-run       Preview actions without making changes"
    echo "  -l, --list          List available components"
    echo "  --skip COMPONENT    Skip a specific component"
    echo "  --only COMPONENTS   Run only specified components (comma-separated)"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                          # Run all components"
    echo "  $0 --check                  # Check installation status"
    echo "  $0 --dry-run                # Preview all actions"
    echo "  $0 --only neovim,dotfiles   # Install only neovim and dotfiles"
    echo "  $0 --skip deps              # Run all except dependencies"
}

list_components() {
    echo "Available components:"
    echo ""
    for name in deps neovim dotfiles ohmyzsh opencode fonts; do
        local entry="${COMPONENTS[$name]}"
        local desc="${entry##*|}"
        printf "  %-12s %s\n" "$name" "$desc"
    done
}

check_component() {
    local name="$1"
    local entry="${COMPONENTS[$name]}"
    local check_cmd="${entry##*|}"
    
    if eval "$check_cmd" &> /dev/null; then
        echo -e "  ${GREEN}[X]${NC} $name"
        return 0
    else
        echo -e "  ${RED}[ ]${NC} $name"
        return 1
    fi
}

check_all() {
    echo "Checking installation status..."
    echo ""
    
    local all_installed=true
    for name in deps neovim dotfiles ohmyzsh opencode fonts; do
        if ! check_component "$name"; then
            all_installed=false
        fi
    done
    
    echo ""
    if $all_installed; then
        log_info "All components are installed!"
    else
        log_info "Some components are not installed. Run without --check to install."
    fi
}

get_component_script() {
    local name="$1"
    local entry="${COMPONENTS[$name]}"
    local script="${entry%%|*}"
    echo "$SCRIPT_DIR/$script"
}

run_component() {
    local name="$1"
    local entry="${COMPONENTS[$name]}"
    local script="${entry%%|*}"
    local desc="${entry#*|}"
    desc="${desc%|*}"
    
    if [[ " ${COMPONENTS_TO_SKIP[@]} " =~ " $name " ]]; then
        log_info "Skipping: $desc"
        return
    fi
    
    if [ ${#COMPONENTS_TO_RUN[@]} -gt 0 ]; then
        if [[ ! " ${COMPONENTS_TO_RUN[@]} " =~ " $name " ]]; then
            return
        fi
    fi
    
    log_step "Running: $desc"
    
    local full_script="$SCRIPT_DIR/$script"
    if [ ! -f "$full_script" ]; then
        log_error "Script not found: $full_script"
        return 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        DRY_RUN=true bash "$full_script"
    else
        bash "$full_script"
    fi
}

parse_args() {
    local run_all=true
    local only_specified=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--all)
                run_all=true
                shift
                ;;
            -c|--check)
                CHECK_MODE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -l|--list)
                list_components
                exit 0
                ;;
            --skip)
                shift
                if [ -z "$1" ]; then
                    log_error "--skip requires a component name"
                    exit 1
                fi
                COMPONENTS_TO_SKIP+=("$1")
                shift
                ;;
            --only)
                shift
                if [ -z "$1" ]; then
                    log_error "--only requires component names"
                    exit 1
                fi
                IFS=',' read -ra COMPONENTS_TO_RUN <<< "$1"
                run_all=false
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                COMPONENTS_TO_RUN+=("$1")
                run_all=false
                shift
                ;;
        esac
    done
}

parse_args "$@"

echo "=========================================="
echo "Development Environment Setup"
echo "=========================================="
echo ""

if [ "$CHECK_MODE" = true ]; then
    check_all
    exit 0
fi

if [ "$DRY_RUN" = true ]; then
    log_info "Running in DRY-RUN mode - no changes will be made"
    echo ""
fi

for name in deps neovim dotfiles ohmyzsh opencode fonts; do
    run_component "$name"
done

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Your development environment is now configured."
echo ""
echo "Next steps:"
echo "  1. Open a new terminal or run: source ~/.zshrc"
echo "  2. Start using tmux: tmux"
echo "  3. Start using Neovim: nvim"
echo "  4. Start using opencode: opencode"
