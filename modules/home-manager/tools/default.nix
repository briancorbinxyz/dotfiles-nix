{ config, pkgs, lib, ... }:

{
  imports = [
    ./git.nix
    ./atuin.nix
    ./bat.nix
    ./fzf.nix
  ];
}
