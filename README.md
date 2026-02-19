# dev-env

My personal Linux development environment setup scripts and configuration files.

## Overview

This repository contains scripts and dotfiles for quickly setting up a development environment on a fresh Fedora Linux system. It includes:

- **Dotfiles**: Configuration files for bash and tmux
- **Install Scripts**: Automated installation of Neovim, tmux, and development dependencies
- **User Setup**: Script for creating a sudo-enabled SSH user

## Quick Start

### Full Setup (All Components)

To set up everything in one go:

```bash
git clone https://github.com/colinhect/dev-env.git
cd dev-env
./scripts/setup.sh
```

### Individual Components

You can also run individual setup scripts:

#### Install Dependencies Only
```bash
./scripts/install-dependencies.sh
```

Installs:
- Development tools (clang, gcc, make, cmake, git)
- tmux
- Python 3 + pip + pynvim
- Node.js + npm
- tree-sitter CLI
- ripgrep, fd-find, fzf
- Various utilities (htop, tree, wget, curl, etc.)

#### Install Neovim Only
```bash
./scripts/install-neovim.sh
```

Downloads and installs the latest Neovim nightly build to `/usr/local`.

#### Install Dotfiles Only
```bash
./scripts/install-dotfiles.sh
```

Copies dotfiles to your home directory (backs up existing files).

#### Setup a New User (For Fresh Systems)
```bash
sudo ./scripts/setup-user.sh [username]
```

Creates a new user with:
- Sudo access (added to wheel group)
- SSH directory configured
- Home directory with proper permissions

## Dotfiles

### .bashrc
- Custom aliases (ll, la, git shortcuts)
- Colored prompt
- History settings
- Sets nvim as default editor

### .tmux.conf
- Prefix changed to Ctrl-a
- Intuitive pane splitting (| and -)
- Mouse support
- Vi mode for copy mode
- Custom status bar

## Options

The main setup script supports these options:

```bash
./scripts/setup.sh [OPTIONS]

Options:
  --skip-deps       Skip installation of dependencies
  --skip-neovim     Skip installation of Neovim
  --skip-dotfiles   Skip installation of dotfiles
  --help            Show help message
```

## Requirements

- Fedora Linux (or RHEL-based distribution with dnf)
- Internet connection
- Sudo access for system-wide installations

## Post-Installation

After running the setup:

1. **Reload shell configuration**:
   ```bash
   source ~/.bashrc
   ```

2. **Start tmux**:
   ```bash
   tmux
   ```

3. **Launch Neovim**:
   ```bash
   nvim
   ```

## License

MIT
