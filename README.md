# dotfiles-nix

Cross-platform dotfiles managed with Nix flakes and home-manager.

## Supported Platforms

| Configuration | Architecture | Use Case |
|--------------|--------------|----------|
| `aarch64-darwin` | Apple Silicon Mac | nix-darwin + home-manager + Homebrew |
| `x86_64-linux` | Intel/AMD Linux | standalone home-manager |
| `steamdeck` | Steam Deck | standalone home-manager with `deck` persona (see [Steam Deck](#steam-deck)) |
| `aarch64-linux` | ARM Linux (Pi, etc.) | standalone home-manager |

## Installation

> **Warning**: Installation requires `sudo` access. The install script and nix-darwin commands modify system-level configurations.

### Quick Install (recommended)

Run the bootstrap script - it handles everything (Nix, cloning, configuration):

```bash
curl -fsSL https://raw.githubusercontent.com/briancorbinxyz/dotfiles-nix/main/install.sh | bash
```

Or, if you prefer to inspect the script first:

```bash
curl -fsSL https://raw.githubusercontent.com/briancorbinxyz/dotfiles-nix/main/install.sh -o install.sh
less install.sh  # review the script
bash install.sh
```

### Manual Install

1. Install [Nix](https://nixos.org/):
```bash
sh <(curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix) install
```

2. Clone and apply:
```bash
git clone https://github.com/briancorbinxyz/dotfiles-nix.git ~/dotfiles-nix
cd ~/dotfiles-nix
# Then run nix-init command for your platform (see Usage below)
```

## Usage

After initial setup, use the cross-platform aliases:
```bash
nix-init      # First time setup
nix-rebuild   # Subsequent updates
```

### Manual Commands

**macOS (nix-darwin)**:
```bash
# First time (requires sudo and experimental features)
sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/dotfiles-nix#aarch64-darwin

# Subsequent updates
sudo darwin-rebuild switch --flake ~/dotfiles-nix#aarch64-darwin
```

**Linux (standalone home-manager)** - auto-detects architecture:
```bash
# First time
nix run home-manager/master -- switch --flake ~/dotfiles-nix#$(uname -m)-linux

# Subsequent updates
home-manager switch --flake ~/dotfiles-nix#$(uname -m)-linux
```

### Steam Deck

SteamOS uses an immutable filesystem, so additional steps are required before installing Nix:

```bash
# 1. Disable read-only mode
sudo steamos-readonly disable

# 2. Create Nix directories (must be root-owned)
sudo mkdir -p /nix /nix/var /nix/var/nix /nix/var/nix/db /nix/var/nix/gcroots /nix/var/nix/profiles /nix/var/nix/temproots /nix/var/nix/userpool /nix/var/log/nix /nix/var/log/nix/drvs
sudo chown -R root:root /nix

# 3. Install Nix
sh <(curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix) install

# 4. Re-enable read-only mode
sudo steamos-readonly enable
```

Then apply the Steam Deck configuration (uses `deck` user persona):

```bash
# First time
nix run home-manager/master -- switch --flake ~/dotfiles-nix#steamdeck

# Subsequent updates
home-manager switch --flake ~/dotfiles-nix#steamdeck
```

> **Note**: SteamOS updates may reset the filesystem. You may need to repeat these steps after major system updates.

## Structure

```
dotfiles-nix/
├── flake.nix                    # Main flake entry point
├── hosts/                       # Host-specific configurations
│   ├── aarch64-darwin/          # macOS Apple Silicon
│   ├── x86_64-linux/            # Linux x86_64 (+ Steam Deck)
│   └── aarch64-linux/           # Linux ARM64
├── personas/                    # User personas (briancorbin, deck, etc.)
├── modules/home-manager/        # Shared home-manager modules
│   ├── shell/                   # Zsh, aliases
│   ├── editors/                 # Neovim
│   ├── terminal/                # Alacritty, Ghostty, tmux
│   ├── tools/                   # Git, atuin, bat, fzf
│   └── packages/                # Base + platform-specific packages
└── dotfiles/                    # Raw config files (nvim, etc.)
```

## What's Managed

### Via Nix (all platforms)
- Shell tools: atuin, bat, fd, fzf, git, gh, jq, lsd, pay-respects, ripgrep, tmux, yq, zoxide
- Development: grpcurl, httpie, websocat, hyperfine, bitwarden-cli
- Editor: Neovim with LSP dependencies

### Via Homebrew (macOS only)
- GUI apps: Alacritty, Ghostty, Docker Desktop, VS Code, Obsidian, etc.
- CLI tools: asdf, gemini-cli, mas, node, pixi, pyenv, rust, terraform
- Fonts: MesloLGS Nerd Font

### Dotfiles (managed via home-manager)
- Zsh with oh-my-zsh and powerlevel10k
- Neovim (LazyVim configuration)
- Alacritty/Ghostty terminal configs
- Git configuration
- tmux configuration

### Notable Aliases

| Alias | Description |
|-------|-------------|
| `brain-sync` | Sync Obsidian vault (Brain) to website repo's `content/` |
| `brain-publish` | Sync, commit, and push to deploy the website |
| `nix-rebuild` | Rebuild nix configuration for current platform |
| `c` / `cr` / `cx` | Claude Code shortcuts |
