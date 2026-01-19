{ config, pkgs, lib, ... }:

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

    # AI (on macOS installed via Homebrew cask)
    ollama
  ];
}
