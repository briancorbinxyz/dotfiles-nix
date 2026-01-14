{ config, pkgs, lib, ... }:

{
  # Ghostty config (macOS via Homebrew cask, Linux when available)
  xdg.configFile."ghostty/config".text = ''
    # Font
    font-family = MesloLGS Nerd Font Mono
    font-size = ${if pkgs.stdenv.isDarwin then "18" else "14"}

    # Window
    window-padding-x = 10
    window-padding-y = 10
    window-decoration = true
    background-opacity = 0.7
    background-blur-radius = 20

    ${lib.optionalString pkgs.stdenv.isDarwin ''
    # macOS specific
    macos-option-as-alt = true
    ''}

    # Theme
    theme = dark:tokyonight,light:tokyonight

    # Shell
    shell-integration = zsh
  '';
}
