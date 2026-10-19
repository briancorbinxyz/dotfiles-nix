{
  config,
  pkgs,
  lib,
  nixglPkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # Development tools that work well via Nix on Linux
    rustup
    terraform
    nodejs
  ] ++ lib.optionals (!config.nominix.wsl.enable) [
    # Desktop Linux only: on WSL, Windows provides the terminal, fonts, clipboard and GUI

    # Terminal emulator (on macOS this is installed via Homebrew cask)
    alacritty

    # Fonts (Nerd Font for starship prompt glyphs)
    nerd-fonts.meslo-lg

    # Clipboard utilities
    xclip
    xdg-utils

    # Graphics/OpenGL wrapper (needed for GUI apps on non-NixOS systems like Steam Deck)
    # Run apps with: nixGLDefault ghostty
    nixglPkgs.nixGLDefault

    # AI (on macOS installed via Homebrew cask; on WSL run the Windows install)
    ollama

    # GUI apps (on macOS these are installed via Homebrew cask)
    ghostty
    obsidian
    dropbox
  ];
}
