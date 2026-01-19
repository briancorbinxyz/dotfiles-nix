{ config, pkgs, lib, user, ... }:

{
  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = "24.05";
  };

  # x86_64-linux specific settings
  home.packages = with pkgs; [
    btop
  ];

  # Konsole configuration (for KDE/Steam Deck)
  xdg.dataFile."konsole/Zsh.profile".text = ''
    [Appearance]
    ColorScheme=Breeze
    Font=MesloLGS Nerd Font Mono,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

    [General]
    Command=${pkgs.zsh}/bin/zsh
    Name=Zsh
    Parent=FALLBACK/
  '';

  xdg.configFile."konsolerc".text = ''
    [Desktop Entry]
    DefaultProfile=Zsh.profile

    [General]
    ConfigVersion=1
  '';
}
