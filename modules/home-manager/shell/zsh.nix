{ config, pkgs, lib, user, ... }:

let
  aliases = import ./aliases.nix { inherit pkgs lib; };
in
{
  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      share = true;
      ignoreDups = true;
      expireDuplicatesFirst = true;
      path = "${config.home.homeDirectory}/.zhistory";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "agnoster";
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    shellAliases = aliases;

    initExtraFirst = ''
      # Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';

    initExtra = ''
      # Source p10k config if exists
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Initialize tools
      eval "$(zoxide init zsh)"
      eval "$(pay-respects zsh --alias oops)"
      eval "$(atuin init zsh)"

      # FZF configuration
      export FZF_COMPLETION_TRIGGER='``'
      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

      # History search with arrow keys
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward

      # Functions
      mkcd() { mkdir -p "$1" && cd "$1" }

      ${lib.optionalString pkgs.stdenv.isDarwin ''
      # Homebrew
      eval "$(/opt/homebrew/bin/brew shellenv)"

      # pyenv
      if command -v pyenv &> /dev/null; then
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
      fi

      # asdf
      if [ -f "$(brew --prefix asdf)/libexec/asdf.sh" ]; then
        . "$(brew --prefix asdf)/libexec/asdf.sh"
      fi

      # Conda (if installed)
      __conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
      if [ $? -eq 0 ]; then
        eval "$__conda_setup"
      else
        if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
          . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
        fi
      fi
      unset __conda_setup

      # Android SDK
      export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
      export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
      ''}

      ${lib.optionalString pkgs.stdenv.isLinux ''
      # Linux-specific initialization
      export PATH="$HOME/.local/bin:$PATH"
      ''}

      # Common paths
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/node_modules/.bin:$PATH"

      # Dotfiles alias (bare git repo)
      alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
    '';
  };
}
