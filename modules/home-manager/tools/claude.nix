{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.file.".claude/settings.json".source = ../../../dotfiles/.claude/settings.json;
  home.file.".claude/statusline-command.sh" = {
    source = ../../../dotfiles/.claude/statusline-command.sh;
    executable = true;
  };

  # Global skills, vendored under dotfiles/.claude/skills/ and symlinked into
  # ~/.claude/skills/ so they're available in every project. Recursive keeps
  # each file individually linked (preserving the scripts' executable bits) and
  # leaves ~/.claude/skills/ writable for per-project or plugin-managed skills.
  home.file.".claude/skills/skill-creator" = {
    source = ../../../dotfiles/.claude/skills/skill-creator;
    recursive = true;
  };
}
