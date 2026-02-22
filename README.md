# Development Environment

My personal Linux development environment setup for Fedora.

## Quick Start

```bash
git clone https://github.com/colinhect/dev-env.git
cd dev-env
./scripts/setup.sh
```

## Setup Script

The main setup script installs all components by default.

### Options

| Option | Description |
|--------|-------------|
| `-c, --check` | Check what's installed without making changes |
| `-d, --dry-run` | Preview actions without making changes |
| `--only COMPONENTS` | Run only specified components (comma-separated) |
| `--skip COMPONENT` | Skip a specific component |
| `-l, --list` | List available components |
| `-h, --help` | Show help message |

### Examples

```bash
./scripts/setup.sh                          # Install everything
./scripts/setup.sh --check                  # Check installation status
./scripts/setup.sh --dry-run                # Preview all actions
./scripts/setup.sh --only neovim,dotfiles   # Install only neovim and dotfiles
./scripts/setup.sh --skip deps              # Skip dependency installation
```

## Components

| Component | Description |
|-----------|-------------|
| `deps` | System packages (clang, gcc, nodejs, ripgrep, etc.) |
| `neovim` | Neovim nightly build |
| `dotfiles` | Configuration files |
| `ohmyzsh` | Oh My Zsh + plugins |
| `opencode` | opencode CLI |
| `fonts` | AdwaitaMono font |

## Individual Scripts

Each component can be run independently:

```bash
./scripts/install-dependencies.sh    # System packages
./scripts/install-neovim.sh          # Neovim nightly
./scripts/install-ohmyzsh.sh         # Oh My Zsh + plugins
./scripts/install-opencode.sh        # opencode CLI
./scripts/install-dotfiles.sh        # Configuration files
./scripts/setup-user.sh [username]   # Create new sudo user (run as root)
```

## Dotfiles

Install specific dotfiles:

```bash
./scripts/install-dotfiles.sh                  # All dotfiles
./scripts/install-dotfiles.sh shell tmux       # Only shell and tmux
./scripts/install-dotfiles.sh --dry-run nvim   # Preview nvim install
./scripts/install-dotfiles.sh --list           # List components
```

### Available Dotfiles

| Component | Destination |
|-----------|-------------|
| `shell` | `~/.zshrc` |
| `tmux` | `~/.tmux.conf` |
| `nvim` | `~/.config/nvim/init.lua` |
| `nvim-nord` | `~/.local/share/nvim/site/pack/core/opt/nord.nvim/` |
| `wezterm` | `~/.config/wezterm/wezterm.lua` |
| `wezterm-colors` | `~/.config/wezterm/colors/` |
| `opencode` | `~/.config/opencode/opencode.json` |
| `opencode-theme` | `~/.config/opencode/themes/nord-custom.json` |

### Dotfile Modules

Each dotfile has its own install script in `scripts/dotfiles/`:

```bash
./scripts/dotfiles/install-shell.sh
./scripts/dotfiles/install-nvim.sh
./scripts/dotfiles/install-tmux.sh
# ... etc
```

## Requirements

- Fedora Linux (or RHEL-based distro with dnf)
- Internet connection
- Sudo access

## Post-Installation

```bash
source ~/.zshrc      # Reload shell config
tmux                 # Start tmux
nvim                 # Start Neovim
opencode             # Start opencode
```

## Directory Structure

```
dev-env/
├── scripts/
│   ├── lib/
│   │   └── common.sh           # Shared functions
│   ├── dotfiles/
│   │   ├── install-shell.sh
│   │   ├── install-nvim.sh
│   │   └── ...
│   ├── config.sh               # Centralized config
│   ├── setup.sh                # Main orchestrator
│   ├── install-dependencies.sh
│   ├── install-neovim.sh
│   ├── install-ohmyzsh.sh
│   ├── install-opencode.sh
│   ├── install-dotfiles.sh
│   └── setup-user.sh
├── dotfiles/
│   ├── .zshrc
│   ├── .tmux.conf
│   └── .config/
│       ├── nvim/
│       ├── wezterm/
│       └── opencode/
└── fonts/
    └── install.sh
```

## License

MIT
