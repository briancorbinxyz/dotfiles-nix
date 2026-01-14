{ config, pkgs, lib, inputs, user, ... }:

{
  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "root" user.name ];
    };
  };

  # System packages (installed for all users)
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Enable zsh as system shell
  programs.zsh.enable = true;

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
      "pyenv"
      "rust"
      "terraform"
      "node"
      "pixi"
    ];

    # GUI applications
    casks = [
      "alacritty"
      "claude-code"
      "docker-desktop"
      "dropbox"
      "font-meslo-lg-nerd-font"
      "ghostty"
      "github"
      "google-chrome"
      "obsidian"
      "visual-studio-code"
      "zotero"
    ];
  };
}
