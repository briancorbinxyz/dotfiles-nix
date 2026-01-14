{ config, pkgs, lib, ... }:

{
  imports = [
    ./alacritty.nix
    ./ghostty.nix
    ./tmux.nix
  ];
}
