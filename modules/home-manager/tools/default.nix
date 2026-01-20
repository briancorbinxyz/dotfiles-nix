{ config, pkgs, lib, ... }:

{
  imports = [
    ./git.nix
    ./atuin.nix
    ./bat.nix
    ./claude.nix
    ./fzf.nix
    ./opencode.nix
  ];
}
