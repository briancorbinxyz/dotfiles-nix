{ config, pkgs, lib, ... }:

let
  cfg = config.nominix.wsl;
in
{
  # WSL2: Windows Terminal draws the UI and Windows owns the clipboard and browser,
  # so Linux GUI apps, fonts and nixGL are skipped (see packages/linux.nix, terminal/)
  options.nominix.wsl.enable = lib.mkEnableOption "WSL2 integration";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Wayland clipboard through WSLg, picked up by Neovim's clipboard provider
      wl-clipboard
    ];

    # wslview ships with Ubuntu's WSL image (wslu); fall back to explorer.exe
    programs.zsh.initContent = ''
      if command -v wslview >/dev/null 2>&1; then
        export BROWSER=wslview
      else
        export BROWSER=explorer.exe
      fi
    '';
  };
}
