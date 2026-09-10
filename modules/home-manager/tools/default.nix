{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./git.nix
    ./atuin.nix
    ./bat.nix
    ./claude.nix
    ./codex.nix
    ./fzf.nix
    ./opencode.nix
    ./fnm.nix
    ./starship.nix
  ];
}
