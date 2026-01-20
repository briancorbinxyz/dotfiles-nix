{ config, pkgs, lib, ... }:

{
  home.file.".claude/settings.json".source = ../../../dotfiles/.claude/settings.json;
  home.file.".claude/statusline-command.sh" = {
    source = ../../../dotfiles/.claude/statusline-command.sh;
    executable = true;
  };
}
