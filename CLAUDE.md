# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Cross-platform dotfiles repository using **Nix flakes** with **home-manager** and **nix-darwin**. Supports Apple Silicon Mac, x86_64 Linux, ARM Linux (Raspberry Pi), and Steam Deck.

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

Steam Deck (uses `deck` persona):
```bash
nix run home-manager/master -- switch --flake ~/dotfiles-nix#steamdeck  # first time
home-manager switch --flake ~/dotfiles-nix#steamdeck  # updates
```

### Development & Validation

```bash
# Enter dev shell with git and nixfmt
nix develop

# Format Nix files (required before commits)
nixfmt <file.nix>
nixfmt **/*.nix        # Format all Nix files

# Lua formatting (for Neovim config in dotfiles/nvim/)
stylua <file.lua>      # indent_type=Spaces, indent_width=2, column_width=120

# Validate configuration
nix flake check        # Syntax validation
nix flake show         # Show what would be built
nix-rebuild --dry-run  # Test changes without applying

# Build specific configuration (without activating)
nix build .#darwinConfigurations.aarch64-darwin.system
nix build .#homeConfigurations.x86_64-linux.activationPackage
```

## Architecture

### Configuration Layers

```
flake.nix                           # Entry point - defines all host configurations
├── hosts/
│   ├── aarch64-darwin/default.nix  # macOS: nix-darwin system settings + Homebrew
│   ├── x86_64-linux/default.nix    # Linux x86_64: standalone home-manager
│   └── aarch64-linux/default.nix   # Linux ARM: lighter config for Pi, etc.
├── personas/                       # User personas (name, email, etc.)
│   ├── briancorbin.nix             # Default persona
│   └── deck.nix                    # Steam Deck persona
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
5. **Personas**: User identity (name, email) defined in `personas/` and passed to configurations via `extraSpecialArgs`

### Common Nix Patterns

Platform-specific packages:
```nix
home.packages = with pkgs; [
  git neovim  # cross-platform
] ++ lib.optionals pkgs.stdenv.isDarwin [
  # macOS-only
] ++ lib.optionals pkgs.stdenv.isLinux [
  # Linux-only
];
```

Platform-specific aliases:
```nix
shellAliases = {
  ll = "lsd -la";  # common
} // lib.optionalAttrs pkgs.stdenv.isDarwin {
  copy = "pbcopy";
} // lib.optionalAttrs pkgs.stdenv.isLinux {
  copy = "xclip -selection clipboard";
};
```

Conditional configuration strings:
```nix
${lib.optionalString pkgs.stdenv.isDarwin ''
  # macOS-specific config
''}
```

### Neovim Setup

Uses **LazyVim** framework. Custom plugins defined in `dotfiles/nvim/lua/plugins/briancorbinxyz.lua`. LSP servers (pyright, typescript-language-server, nil, rust-analyzer) installed via home-manager's `extraPackages`, not Mason.

### Shell Integration

Zsh is primary shell with oh-my-zsh + powerlevel10k. Tool integrations (zoxide, atuin, fzf, pay-respects) configured in `modules/home-manager/shell/zsh.nix`. Modern aliases (bat→cat, lsd→ls) in `aliases.nix`.

## Adding New Configuration

1. **New tool/application**: Create module in `modules/home-manager/<category>/` and import in that category's `default.nix`
2. **New shell alias**: Add to `modules/home-manager/shell/aliases.nix`
3. **New package**: Add to appropriate file in `modules/home-manager/packages/` (default.nix for cross-platform, darwin.nix or linux.nix for platform-specific)
4. **Complex raw config**: Place in `dotfiles/` and symlink via `xdg.configFile` in the relevant module
5. **macOS GUI app**: Add to Homebrew casks in `hosts/aarch64-darwin/default.nix`
