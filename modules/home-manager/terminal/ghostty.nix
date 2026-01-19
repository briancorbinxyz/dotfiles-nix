{ config, pkgs, lib, ... }:

{
  # Ghostty config (macOS via Homebrew cask, Linux when available)
  xdg.configFile."ghostty/config".text = ''
    # Font
    font-family = MesloLGS Nerd Font Mono
    font-size = ${if pkgs.stdenv.isDarwin then "14" else "12"}

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
    theme = dark:TokyoNight,light:TokyoNight Day

    # Shell
    command = zsh
    shell-integration = zsh
  '';

  # Desktop entry for Linux with nixGL wrapper
  xdg.desktopEntries = lib.mkIf pkgs.stdenv.isLinux {
    ghostty = {
      name = "Ghostty";
      comment = "A terminal emulator";
      exec = "nixGL ghostty";
      icon = "ghostty";
      terminal = false;
      type = "Application";
      categories = [ "System" "TerminalEmulator" ];
    };
  };
}
