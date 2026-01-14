{ config, pkgs, lib, ... }:

{
  programs.atuin = {
    enable = true;
    enableZshIntegration = false; # We handle this in zsh.nix initExtra

    settings = {
      auto_sync = true;
      sync_frequency = "10m";
      search_mode = "fuzzy";
      filter_mode = "global";
      style = "auto";
      enter_accept = true;
      secrets_filter = true;

      sync = {
        records = true;
      };
    };
  };
}
