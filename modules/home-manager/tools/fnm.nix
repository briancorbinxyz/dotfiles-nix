{ config, pkgs, lib, ... }:

{
  programs.fnm = {
    enable = true;
    enableZshIntegration = true;
  };
}
