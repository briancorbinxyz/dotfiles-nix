# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Cross-platform dotfiles repository using **Nix flakes** with **home-manager** and **nix-darwin**. Supports Apple Silicon Mac, x86_64 Linux, and ARM Linux (Raspberry Pi, etc.).

## Common Commands

### Apply Configuration

After initial setup, use the cross-platform aliases:
```bash
nix-init      # First time setup
nix-rebuild   # Subsequent updates
```

**Manual commands (if aliases unavailable)**:

macOS:
```bash
sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/dotfiles-nix#aarch64-darwin  # first time
sudo darwin-rebuild switch --flake ~/dotfiles-nix#aarch64-darwin  # updates
```

Linux (auto-detects x86_64/aarch64):
```bash
nix run home-manager/master -- switch --flake ~/dotfiles-nix#$(uname -m)-linux  # first time
home-manager switch --flake ~/dotfiles-nix#$(uname -m)-linux  # updates
```

### Development

```bash
# Enter dev shell with git and nixfmt
nix develop

# Format Nix files
nixfmt <file.nix>
```

## Architecture

### Configuration Layers

```
flake.nix                           # Entry point - defines all host configurations
├── hosts/
│   ├── aarch64-darwin/default.nix  # macOS: nix-darwin system settings + Homebrew
│   ├── x86_64-linux/default.nix    # Linux x86_64: standalone home-manager
│   └── aarch64-linux/default.nix   # Linux ARM: lighter config for Pi, etc.
├── modules/
│   ├── darwin/                     # nix-darwin modules (system-level macOS)
│   └── home-manager/               # User-level modules (all platforms)
│       ├── shell/                  # zsh.nix, aliases.nix
│       ├── editors/                # neovim.nix
│       ├── terminal/               # alacritty.nix, ghostty.nix, tmux.nix
│       ├── tools/                  # git.nix, atuin.nix, bat.nix, fzf.nix
│       └── packages/               # default.nix (base), darwin.nix, linux.nix
└── dotfiles/                       # Raw config files symlinked by home-manager
    └── nvim/                       # LazyVim configuration
```

### Key Design Patterns

1. **Platform Detection**: Modules use `pkgs.stdenv.isDarwin` / `pkgs.stdenv.isLinux` for platform-specific settings
2. **Hybrid Package Management**: Nix for CLI tools, Homebrew for macOS GUI apps (configured in `hosts/aarch64-darwin/default.nix`)
3. **Modular home-manager**: Organized by function (shell, editors, terminal, tools) not by application
4. **Raw Dotfiles**: Complex configs like Neovim live in `dotfiles/` and are symlinked via `xdg.configFile`

### Neovim Setup

Uses **LazyVim** framework. Custom plugins defined in `dotfiles/nvim/lua/plugins/briancorbinxyz.lua`. LSP servers (pyright, typescript-language-server, nil, rust-analyzer) installed via home-manager's `extraPackages`, not Mason.

### Shell Integration

Zsh is primary shell with oh-my-zsh + powerlevel10k. Tool integrations (zoxide, atuin, fzf, pay-respects) configured in `modules/home-manager/shell/zsh.nix`. Modern aliases (bat→cat, lsd→ls) in `aliases.nix`.
