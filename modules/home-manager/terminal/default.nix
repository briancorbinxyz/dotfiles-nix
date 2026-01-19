{ config, pkgs, lib, ... }:

{
  imports = [
    ./alacritty.nix
    ./ghostty.nix
    ./konsole.nix
    ./tmux.nix
  ];
}
