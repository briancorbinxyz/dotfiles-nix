{ config, pkgs, lib, ... }:

{
  # On macOS, alacritty is installed via Homebrew cask
  # On Linux, it's installed via packages/linux.nix
  programs.alacritty = {
    enable = pkgs.stdenv.isLinux;
  };

  # Configuration file (works on both platforms)
  xdg.configFile."alacritty/alacritty.toml".text = ''
    [env]
    TERM = "xterm-256color"

    [window]
    padding.x = 10
    padding.y = 10
    decorations = "Buttonless"
    opacity = 0.7
    blur = true
    ${lib.optionalString pkgs.stdenv.isDarwin ''
    option_as_alt = "Both"
    ''}

    [font]
    normal.family = "MesloLGS Nerd Font Mono"
    size = ${if pkgs.stdenv.isDarwin then "18" else "14"}

    [colors.primary]
    background = "#1a1b26"
    foreground = "#c0caf5"

    [colors.normal]
    black = "#15161e"
    red = "#f7768e"
    green = "#9ece6a"
    yellow = "#e0af68"
    blue = "#7aa2f7"
    magenta = "#bb9af7"
    cyan = "#7dcfff"
    white = "#a9b1d6"

    [colors.bright]
    black = "#414868"
    red = "#f7768e"
    green = "#9ece6a"
    yellow = "#e0af68"
    blue = "#7aa2f7"
    magenta = "#bb9af7"
    cyan = "#7dcfff"
    white = "#c0caf5"
  '';
}
