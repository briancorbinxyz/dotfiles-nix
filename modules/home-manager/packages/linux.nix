{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Terminal emulator (on macOS this is installed via Homebrew cask)
    alacritty

    # Development tools that work well via Nix on Linux
    rustup
    terraform
    nodejs

    # Clipboard utilities
    xclip
    xdg-utils
  ];
}
