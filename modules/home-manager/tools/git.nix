{
  config,
  pkgs,
  lib,
  user,
  ...
}:

{
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      user = {
        name = user.fullName;
        email = user.email;
      };

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;

      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";

      core.editor = "nvim";

      alias = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
      };
    };

    # A repo with a GitHub remote commits as the GitHub noreply address, so a push is never
    # refused for exposing a private one.
    includes = lib.optionals ((user.githubEmail or null) != null) (
      map
        (url: {
          condition = "hasconfig:remote.*.url:${url}";
          contents.user.email = user.githubEmail;
        })
        [
          "https://github.com/**"
          "git@github.com:*/**"
        ]
    );

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

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      side-by-side = true;
      line-numbers = true;
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
}
