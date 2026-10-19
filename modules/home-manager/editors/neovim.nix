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

    # The provider settings home-manager generates (ruby/python3 host progs)
    # would otherwise be written to ~/.config/nvim/init.lua, which collides
    # with the out-of-store symlink below. Load them via the wrapper instead.
    sideloadInitLua = true;

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

  # Migration: earlier generations linked the config recursively, leaving
  # ~/.config/nvim as a real directory of store links that home-manager will
  # not replace with a symlink. Remove it only if it holds nothing else.
  home.activation.migrateNvimConfigDir = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    nvimDir="${config.xdg.configHome}/nvim"
    if [ -d "$nvimDir" ] && [ ! -L "$nvimDir" ] \
      && [ -z "$(find "$nvimDir" ! -type d ! -lname '/nix/store/*' -print -quit)" ]; then
      verboseEcho "Removing old recursively linked $nvimDir"
      run rm -rf "$nvimDir"
    fi
  '';
}
