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
}
