{ config, pkgs, lib, nixglPkgs, ... }:

{
  home.packages = with pkgs; [
    # Terminal emulator (on macOS this is installed via Homebrew cask)
    alacritty

    # Fonts (Nerd Font for powerlevel10k)
    nerd-fonts.meslo-lg

    # Development tools that work well via Nix on Linux
    rustup
    terraform
    nodejs

    # Clipboard utilities
    xclip
    xdg-utils

    # Graphics/OpenGL wrapper (needed for GUI apps on non-NixOS systems like Steam Deck)
    # Run apps with: nixGLDefault ghostty
    nixglPkgs.nixGLDefault

    # AI (on macOS installed via Homebrew cask)
    ollama

    # GUI apps (on macOS these are installed via Homebrew cask)
    ghostty
    obsidian
    dropbox
  ];
}
