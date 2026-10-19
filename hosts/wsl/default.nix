{ config, pkgs, lib, user, ... }:

{
  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = "24.05";
  };

  # WSL2 (x86_64): CLI only, Windows handles terminal, clipboard and browser
  nominix.wsl.enable = true;
}
