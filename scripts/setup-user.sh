#!/bin/bash
# Script to create a new user with sudo access and SSH setup on Fedora

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Get username from argument or prompt
if [ -z "$1" ]; then
    read -p "Enter username to create: " USERNAME
else
    USERNAME="$1"
fi

# Validate username
if [ -z "$USERNAME" ]; then
    echo "Error: Username cannot be empty"
    exit 1
fi

# Check if user already exists
if id "$USERNAME" &>/dev/null; then
    echo "Error: User $USERNAME already exists"
    exit 1
fi

echo "Creating user: $USERNAME"

# Create the user
useradd -m -s /bin/bash "$USERNAME"

# Set password
echo "Setting password for $USERNAME"
passwd "$USERNAME"

# Add user to wheel group for sudo access
echo "Adding $USERNAME to wheel group for sudo access..."
usermod -aG wheel "$USERNAME"

# Setup SSH directory
echo "Setting up SSH directory..."
USER_HOME="/home/$USERNAME"
SSH_DIR="$USER_HOME/.ssh"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Create authorized_keys file
touch "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/authorized_keys"

# Set proper ownership
chown -R "$USERNAME:$USERNAME" "$SSH_DIR"

echo ""
echo "User $USERNAME created successfully!"
echo ""
echo "Next steps:"
echo "  1. Add SSH public key to: $SSH_DIR/authorized_keys"
echo "  2. Ensure /etc/sudoers allows wheel group (should be default on Fedora)"
echo "  3. Test SSH access: ssh $USERNAME@<server-ip>"
echo "  4. Test sudo access: sudo -l"
echo ""
echo "To add an SSH key, you can:"
echo "  - Manually edit: $SSH_DIR/authorized_keys"
echo "  - Or run: echo 'YOUR_PUBLIC_KEY' >> $SSH_DIR/authorized_keys"
