{ config, pkgs, lib, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];

    fileWidget.command = "fd --type f --hidden --follow --exclude .git";
    changeDirWidget.command = "fd --type d --hidden --follow --exclude .git";
  };
}
