# AGENTS.md

This file provides guidance for agentic coding assistants working in this Nix flake-based dotfiles repository.

## Repository Overview

Cross-platform dotfiles repository using **Nix flakes** with **home-manager** and **nix-darwin**. Supports Apple Silicon Mac, x86_64 Linux, and ARM Linux (Raspberry Pi, etc.).

## Build/Development Commands

### Core Commands
```bash
# Apply configuration (first time setup)
nix-init      # Cross-platform alias
# Manual: sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/dotfiles-nix#aarch64-darwin

# Update configuration (subsequent changes)
nix-rebuild   # Cross-platform alias  
# Manual: sudo darwin-rebuild switch --flake ~/dotfiles-nix#aarch64-darwin

# Enter development shell
nix develop   # Provides git and nixfmt
```

### Formatting & Linting
```bash
# Format Nix files (required before commits)
nixfmt <file.nix>
nixfmt **/*.nix    # Format all Nix files

# Shell script formatting
shfmt <script.sh>

# Lua formatting (for Neovim config)
stylua <file.lua>
# Config: indent_type=Spaces, indent_width=2, column_width=120
```

### Validation
```bash
# Test configuration changes (dry run)
nix-rebuild --dry-run

# Check flake outputs
nix flake check

# Show what would be built
nix flake show
```

## Code Style Guidelines

### Nix Files
- **Indentation**: 2 spaces (nixfmt default)
- **Line width**: No strict limit, but prefer reasonable lengths
- **Imports**: Use relative imports for modules, absolute for packages
- **Attribute naming**: camelCase for options, snake_case for variables
- **File structure**: Modular organization by function (shell/, editors/, tools/)

### Import Patterns
```nix
# Good: Relative imports for modules
imports = [
  ./shell/zsh.nix
  ./editors/neovim.nix
];

# Good: Absolute imports for packages
home.packages = with pkgs; [ git neovim ];
```

### Module Structure
```nix
{ config, pkgs, lib, user, ... }:  # Standard arguments

{
  # Configuration here
  programs.tool.enable = true;
  
  # Conditional platform settings
  ${lib.optionalString pkgs.stdenv.isDarwin ''
    # macOS-specific
  ''}
  
  ${lib.optionalString pkgs.stdenv.isLinux ''
    # Linux-specific  
  ''}
}
```

### Naming Conventions
- **Files**: kebab-case (e.g., `neovim.nix`, `shell-aliases.nix`)
- **Options**: camelCase (e.g., `enableZshIntegration`)
- **Variables**: snake_case (e.g., `common_packages`)
- **Aliases**: Short, intuitive (e.g., `ll`, `gst`, `vf`)

### Error Handling
- Use `lib.mkDefault` for sensible defaults
- Use `lib.mkForce` only when necessary to override
- Provide clear error messages in custom modules
- Use `lib.optionalString` for conditional configuration

### Platform Detection
```nix
# Standard pattern
${lib.optionalString pkgs.stdenv.isDarwin ''
  # macOS-specific configuration
''}

${lib.optionalString pkgs.stdenv.isLinux ''
  # Linux-specific configuration
''}
```

## Configuration Patterns

### Home Manager Modules
- Organize by function: `shell/`, `editors/`, `terminal/`, `tools/`
- Use `xdg.configFile` for complex configurations
- Prefer Nix options over raw dotfiles when possible

### Package Management
- CLI tools via Nix packages
- macOS GUI apps via Homebrew (in `hosts/aarch64-darwin/default.nix`)
- Language-specific tools via respective modules

### Shell Integration
- Zsh as primary shell with oh-my-zsh + powerlevel10k
- Tool integrations in `shell/zsh.nix` initContent
- Modern aliases in `shell/aliases.nix`

## Testing Strategy

### Configuration Testing
```bash
# Test specific host configuration
nix build .#darwinConfigurations.aarch64-darwin.system
nix build .#homeConfigurations.x86_64-linux.activationPackage

# Dry run activation
home-manager switch --flake .#x86_64-linux --dry-run
```

### Single Component Testing
Since this is a configuration repository, "testing" means:
1. **Syntax validation**: `nix flake check`
2. **Formatting**: `nixfmt` on all modified files
3. **Dry run**: `nix-rebuild --dry-run` before applying
4. **Manual verification**: Apply to test system when possible

## Git Workflow

### Commit Requirements
- **Format**: Run `nixfmt` on all modified `.nix` files
- **Message**: Use conventional commits (feat:, fix:, refactor:, etc.)
- **Scope**: Indicate affected area (shell, editors, darwin, linux)

### Branch Strategy
- `main`: Stable configuration
- Feature branches for major changes
- Test changes on non-production systems first

## Common Patterns

### Conditional Packages
```nix
home.packages = with pkgs; [
  # Cross-platform
  git neovim
  
  # Platform-specific
] ++ lib.optionals pkgs.stdenv.isDarwin [
  # macOS-only packages
] ++ lib.optionals pkgs.stdenv.isLinux [
  # Linux-only packages
];
```

### Aliases with Platform Detection
```nix
shellAliases = {
  # Common aliases
  ll = "lsd -la";
  
} // lib.optionalAttrs pkgs.stdenv.isDarwin {
  # macOS aliases
  copy = "pbcopy";
  
} // lib.optionalAttrs pkgs.stdenv.isLinux {
  # Linux aliases  
  copy = "xclip -selection clipboard";
};
```

## File Organization

```
flake.nix                    # Entry point
├── hosts/                   # Platform-specific configs
├── modules/                 # Reusable modules
│   ├── darwin/             # nix-darwin modules
│   └── home-manager/       # User modules
├── dotfiles/               # Raw configs (symlinked)
└── CLAUDE.md              # This file
```

## Important Notes

- **No secrets**: Never commit sensitive data
- **Cross-platform**: Always test on target platforms
- **Idempotent**: Configuration should be safe to reapply
- **Declarative**: Avoid imperative commands in documentation
- **Minimal**: Only include what's necessary for the configuration