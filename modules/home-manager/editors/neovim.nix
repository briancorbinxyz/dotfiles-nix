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

  # Link ~/.config/nvim straight to the live checkout rather than a Nix store
  # copy, so lazy.nvim can write lazy-lock.json (and LazyVim lazyvim.json)
  # back into the repo, where the changes can be committed. Assumes the repo
  # lives at ~/dotfiles-nix, which is where install.sh clones it.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles-nix/dotfiles/nvim";
}
