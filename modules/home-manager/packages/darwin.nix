{ config, pkgs, lib, ... }:

{
  # macOS-specific packages
  # Most GUI apps and some CLI tools are managed via Homebrew
  # in hosts/corbinm1mac/default.nix

  home.packages = with pkgs; [
    # macOS utilities that work well via Nix
    darwin.trash
  ];
}
