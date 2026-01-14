{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Shell/Terminal tools
    atuin
    thefuck
    tmux
    zoxide

    # File/Text utilities
    bat
    fd
    jq
    lsd
    ripgrep
    yq-go

    # Git/VCS
    git
    gh
    git-lfs
    delta

    # Development tools
    grpcurl
    httpie
    websocat
    hyperfine

    # Security
    bitwarden-cli

    # Build tools
    gnumake
    coreutils

    # Utilities
    tree
    wget
    curl
    unzip
    htop
    btop
  ];
}
