#!/bin/bash
# Script to create a new user with sudo access and SSH setup on Fedora

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/config.sh"

if [ "$EUID" -ne 0 ]; then
    log_error "This script must be run as root"
    exit 1
fi

if [ -z "$1" ]; then
    read -p "Enter username to create: " USERNAME
else
    USERNAME="$1"
fi

if [ -z "$USERNAME" ]; then
    log_error "Username cannot be empty"
    exit 1
fi

if id "$USERNAME" &>/dev/null; then
    log_error "User $USERNAME already exists"
    exit 1
fi

log_info "Creating user: $USERNAME"

log_step "Creating user account..."
useradd -m -s /bin/bash "$USERNAME"

log_step "Setting password..."
passwd "$USERNAME"

log_step "Adding to wheel group for sudo access..."
usermod -aG wheel "$USERNAME"

log_step "Setting up SSH directory..."
USER_HOME="/home/$USERNAME"
SSH_DIR="$USER_HOME/.ssh"

ensure_dir "$SSH_DIR"
chmod 700 "$SSH_DIR"

touch "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/authorized_keys"

chown -R "$USERNAME:$USERNAME" "$SSH_DIR"

log_info "User $USERNAME created successfully!"
echo ""
echo "Next steps:"
echo "  1. Add SSH public key to: $SSH_DIR/authorized_keys"
echo "  2. Test SSH access: ssh $USERNAME@<server-ip>"
echo "  3. Test sudo access: sudo -l"
