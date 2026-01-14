{ config, pkgs, lib, user, ... }:

{
  programs.git = {
    enable = true;
    userName = user.fullName;
    userEmail = user.email;

    lfs.enable = true;

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;

      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";

      core.editor = "nvim";
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
      };
    };

    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      ".idea/"
      ".vscode/"
      "*.log"
      ".env.local"
      ".claude/settings.local.json"
    ];
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
}
