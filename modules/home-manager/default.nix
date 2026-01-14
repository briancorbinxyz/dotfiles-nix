{ config, pkgs, lib, user, ... }:

{
  imports = [
    ./shell
    ./editors
    ./terminal
    ./tools
    ./packages
  ];

  programs.home-manager.enable = true;

  home = {
    username = user.name;
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${user.name}"
      else "/home/${user.name}";
    stateVersion = "24.05";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      LANG = "en_US.UTF-8";
    };
  };

  xdg.enable = true;
}
