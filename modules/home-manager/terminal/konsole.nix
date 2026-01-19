{ config, pkgs, lib, ... }:

{
  # Konsole profile with matching font (Linux/Steam Deck only)
  xdg.dataFile = lib.mkIf pkgs.stdenv.isLinux {
    "konsole/Nix.profile".text = ''
      [Appearance]
      ColorScheme=Breeze
      Font=MesloLGS Nerd Font Mono,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

      [General]
      Command=zsh
      Name=Nix
      Parent=FALLBACK/

      [Scrolling]
      HistoryMode=2

      [Terminal Features]
      BlinkingCursorEnabled=true
    '';

    # Set as default profile
    "konsole/konsolerc".text = ''
      [Desktop Entry]
      DefaultProfile=Nix.profile
    '';
  };
}
