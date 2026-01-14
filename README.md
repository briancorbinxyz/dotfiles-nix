# dotfiles-nix

Cross-platform dotfiles managed with Nix flakes and home-manager.

## Supported Platforms

| Configuration | Architecture | Use Case |
|--------------|--------------|----------|
| `aarch64-darwin` | Apple Silicon Mac | nix-darwin + home-manager + Homebrew |
| `x86_64-linux` | Intel/AMD Linux | standalone home-manager |
| `aarch64-linux` | ARM Linux (Pi, etc.) | standalone home-manager |

## Installation

To use these dotfiles, you need to have [Nix](https://nixos.org/) installed. If you don't have Nix installed, you can install it using the recommended multi-user setup:

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

After installation, please restart your terminal or source your shell configuration file (e.g., `source ~/.zshrc` or `source ~/.bashrc`) to ensure Nix is properly initialized in your environment.

## Usage

### macOS (nix-darwin)

**Note:** Nix Darwin system activation commands must be run with `sudo` and typically require `--extra-experimental-features "nix-command flakes"`.

```bash
# First time setup
sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/dotfiles-nix#aarch64-darwin

# Subsequent updates
sudo darwin-rebuild switch --flake ~/dotfiles-nix#aarch64-darwin
```

### Linux (standalone home-manager)

```bash
# First time setup (x86_64)
nix run home-manager/master -- switch --flake ~/dotfiles-nix#x86_64-linux

# First time setup (aarch64)
nix run home-manager/master -- switch --flake ~/dotfiles-nix#aarch64-linux

# Subsequent updates
home-manager switch --flake ~/dotfiles-nix#x86_64-linux
home-manager switch --flake ~/dotfiles-nix#aarch64-linux
```

## Structure

```
dotfiles-nix/
├── flake.nix                    # Main flake entry point
├── hosts/                       # Host-specific configurations
│   ├── aarch64-darwin/          # macOS Apple Silicon
│   ├── x86_64-linux/            # Linux x86_64
│   └── aarch64-linux/           # Linux ARM64
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
- Shell tools: atuin, bat, fd, fzf, git, gh, jq, lsd, ripgrep, thefuck, tmux, yq, zoxide
- Development: grpcurl, httpie, websocat, hyperfine, bitwarden-cli
- Editor: Neovim with LSP dependencies

### Via Homebrew (macOS only)
- GUI apps: Alacritty, Ghostty, Docker Desktop, VS Code, Obsidian, etc.
- Tools better via Homebrew: asdf, pyenv, rust, terraform, node
- Fonts: MesloLGS Nerd Font

### Dotfiles (managed via home-manager)
- Zsh with oh-my-zsh and powerlevel10k
- Neovim (LazyVim configuration)
- Alacritty/Ghostty terminal configs
- Git configuration
- tmux configuration
