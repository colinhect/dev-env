#!/bin/bash
# Common functions and utilities for dev-env scripts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_step() {
    echo -e "${BLUE}==>${NC} $1"
}

# Get the directory where the script is located
get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

# Get the root directory of dev-env
get_root_dir() {
    local script_dir
    script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
    echo "$script_dir"
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Require a command or exit with error
require_command() {
    if ! command_exists "$1"; then
        log_error "Required command '$1' not found."
        if [ -n "$2" ]; then
            log_error "$2"
        fi
        exit 1
    fi
}

# Check if running with sudo/root access
has_sudo() {
    [ "$EUID" -eq 0 ] || sudo -n true 2>/dev/null
}

# Get sudo prefix (empty if root, 'sudo' otherwise)
get_sudo() {
    if [ "$EUID" -eq 0 ]; then
        echo ""
    else
        echo "sudo"
    fi
}

# Backup a file if it exists
backup_file() {
    local file="$1"
    if [ -f "$file" ] || [ -L "$file" ]; then
        local i=1
        while [ -e "${file}.backup.${i}" ]; do
            ((i++))
        done
        log_warn "Backing up $file to ${file}.backup.${i}"
        mv "$file" "${file}.backup.${i}"
    fi
}

# Backup a directory if it exists (but not if it's a symlink)
backup_dir() {
    local dir="$1"
    if [ -d "$dir" ] && [ ! -L "$dir" ]; then
        local i=1
        while [ -e "${dir}.backup.${i}" ]; do
            ((i++))
        done
        log_warn "Backing up $dir to ${dir}.backup.${i}"
        mv "$dir" "${dir}.backup.${i}"
    fi
}

# Create a temp directory and return its path
create_temp_dir() {
    mktemp -d
}

# Clean up temp directory
cleanup_temp() {
    local temp_dir="$1"
    if [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
    fi
}

# Check if on Fedora/RHEL
is_fedora() {
    command_exists dnf
}

# Detect system architecture for downloads
get_arch() {
    local arch
    arch=$(uname -m)
    case $arch in
        x86_64)
            echo "x86_64"
            ;;
        aarch64|arm64)
            echo "aarch64"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

# Download a file with curl
download_file() {
    local url="$1"
    local output="$2"
    
    require_command curl "curl is required for downloads"
    
    if ! curl -fLo "$output" "$url"; then
        log_error "Failed to download from $url"
        return 1
    fi
    return 0
}

# Install a file to a system path
install_binary() {
    local src="$1"
    local dest="$2"
    local mode="${3:-755}"
    
    local sudo
    sudo=$(get_sudo)
    $sudo install -m "$mode" "$src" "$dest"
}

# Ensure a directory exists
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

# Copy a file with backup
copy_with_backup() {
    local src="$1"
    local dest="$2"
    
    ensure_dir "$(dirname "$dest")"
    backup_file "$dest"
    cp "$src" "$dest"
}

# Copy a directory with backup
copy_dir_with_backup() {
    local src="$1"
    local dest="$2"
    
    ensure_dir "$(dirname "$dest")"
    backup_dir "$dest"
    cp -r "$src" "$dest"
}

# Dry run wrapper - only execute if not in dry-run mode
maybe_run() {
    if [ "$DRY_RUN" = "true" ]; then
        echo "[DRY-RUN] $*"
    else
        "$@"
    fi
}
