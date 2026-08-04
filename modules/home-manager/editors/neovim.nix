{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = true;
    withPython3 = true;

    # Neovim plugins are managed by lazy.nvim, not Nix
    # We just ensure dependencies are available
    extraPackages = with pkgs; [
      # Language servers
      lua-language-server
      pyright
      typescript-language-server
      nil # Nix LSP
      rust-analyzer

      # Formatters and linters
      stylua
      shellcheck
      shfmt
      prettier
      nixfmt

      # Build tools needed by some plugins
      gcc
      gnumake
      nodejs
      python3
    ];
  };

  # Link neovim config directory from dotfiles
  xdg.configFile."nvim" = {
    source = ../../../dotfiles/nvim;
    recursive = true;
  };
}
