{
  config,
  pkgs,
  lib,
  inputs,
  user,
  ...
}:

{
  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = user.name;

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        user.name
      ];
    };
  };

  # System packages (installed for all users)
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Enable zsh as system shell
  programs.zsh.enable = true;

  # Authenticate `sudo` with Touch ID instead of typing a password. nix-darwin
  # manages /etc/pam.d/sudo_local, which Apple keeps across OS updates — unlike
  # editing /etc/pam.d/sudo directly, which every major update reverts.
  #
  # reattach loads pam_reattach, which forwards the request to the GUI login
  # session. Without it Touch ID silently falls back to a password prompt inside
  # tmux (terminal/tmux.nix), which is where most of these sudos get typed.
  #
  # NOTE: this does NOT let Claude Code run `nix-rebuild` — sudo still needs a
  # controlling terminal to prompt on, and session commands have none. See
  # CLAUDE.md; nix-rebuild stays a run-it-yourself command.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # Set Git commit hash for darwin-version
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # macOS system preferences
  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
      minimize-to-application = true;
      show-recents = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
    };

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 14;
      KeyRepeat = 1;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
    };

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };
  };

  # Homebrew integration (for GUI apps and tools better via Homebrew)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "none";
    };

    taps = [ ];

    # CLI tools that work better via Homebrew on macOS
    brews = [
      "asdf"
      "awscli"
      "gemini-cli"
      "mas"
      "node"
      "pixi"
      "podman"
      "pyenv"
      "rust"
      "terraform"
    ];

    # GUI applications
    casks = [
      "alacritty"
      "claude"
      "claude-code"
      "dropbox"
      "font-meslo-lg-nerd-font"
      "ghostty"
      "github"
      "google-chrome"
      "obsidian"
      "ollama-app"
      "podman-desktop"
      "rancher"
      "session-manager-plugin"
      "tailscale-app"
      "termius"
      "visual-studio-code"
      "zoom"
      "zotero"
    ];
  };
}
