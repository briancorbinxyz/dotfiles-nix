{ config, pkgs, lib, user, inputs, ... }:

let
  aliases = import ./aliases.nix { inherit pkgs lib; };
in
{
  home.file.".p10k.zsh".source = ../../../dotfiles/zsh/.p10k.zsh;

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory; # Lock in legacy default (home directory)
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
      {
        name = "pomo";
        src = inputs.pomo;
        file = "pomo.plugin.zsh";
      }
    ];

    shellAliases = aliases;

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Powerlevel10k instant prompt
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      ''
        # Source nominix user configuration if exists (for nix-rebuild)
        [[ ! -f ~/.config/nominix/env ]] || source ~/.config/nominix/env

        # Source p10k config if exists
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # Initialize tools
        eval "$(zoxide init zsh)"
        eval "$(pay-respects zsh --alias oops)"
        eval "$(atuin init zsh)"

        # Pomodoro configuration
        export POMODORO_REALTIME=true

        # FZF configuration
        export FZF_COMPLETION_TRIGGER='``'
        [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

        # History search with arrow keys
        bindkey '^[[A' history-search-backward
        bindkey '^[[B' history-search-forward

        # Functions
        mkcd() { mkdir -p "$1" && cd "$1" }

        # FZF git branch switcher
        gcof() {
          local branches branch
          branches=$(git branch --all --color=always --sort=-committerdate | grep -v HEAD) &&
          branch=$(echo "$branches" | fzf --ansi --no-multi --preview-window right:65% \
            --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})') &&
          git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
        }

        # Nvim + Claude with terminal title
        _nvim_title() {
          if git rev-parse --is-inside-work-tree &>/dev/null; then
            basename "$(git rev-parse --show-toplevel)"
          else
            basename "$PWD"
          fi
        }
        nvc() {
          local name="$(_nvim_title)"
          nvim . -c "lua vim.opt.title=true; vim.opt.titlestring='nvim: $name'" -c 'vsplit | terminal claude'
        }
        nvch() {
          local name="$(_nvim_title)"
          nvim . -c "lua vim.opt.title=true; vim.opt.titlestring='nvim: $name'" -c 'split | terminal claude'
        }
        nvc2() {
          local name="$(_nvim_title)"
          nvim . -c "lua vim.opt.title=true; vim.opt.titlestring='nvim: $name'" -c 'vsplit | terminal claude' -c 'split | terminal claude'
        }
        nvc22() {
          local name="$(_nvim_title)"
          nvim . -c "lua vim.opt.title=true; vim.opt.titlestring='nvim: $name'" -c 'vsplit | terminal claude' -c 'vsplit | terminal claude' -c 'wincmd h | split | terminal claude' -c 'wincmd l | split | terminal claude'
        }
        nvc4() {
          local name="$(_nvim_title)"
          nvim . -c "lua vim.opt.title=true; vim.opt.titlestring='nvim: $name'" -c 'terminal claude' -c 'vsplit | terminal claude' -c 'split | terminal claude' -c 'wincmd h | split | terminal claude'
        }
        tnvc() {
          local name="$(_nvim_title)"
          local session="''${name//-/_}"
          tmux new-session -d -s "$session" 'nvim .'
          tmux split-window -t "$session" -h -l 50% 'claude'
          tmux select-pane -t "$session" -L
          tmux attach-session -t "$session"
        }
        tnvc2() {
          local name="$(_nvim_title)"
          local session="''${name//-/_}"
          tmux new-session -d -s "$session" 'nvim .'
          tmux split-window -t "$session" -h -l 50% 'claude'
          tmux split-window -t "$session" -v 'claude'
          tmux select-pane -t "$session" -L
          tmux attach-session -t "$session"
        }
        tnvc4() {
          local name="$(_nvim_title)"
          local session="''${name//-/_}"
          tmux new-session -d -s "$session" 'nvim .'
          tmux split-window -t "$session" -h -l 66% 'claude'
          tmux split-window -t "$session" -h -l 50% 'claude'
          tmux select-pane -t "$session" -L
          tmux split-window -t "$session" -v 'claude'
          tmux select-pane -t "$session" -R
          tmux split-window -t "$session" -v 'claude'
          tmux select-pane -t "$session" -L
          tmux select-pane -t "$session" -L
          tmux attach-session -t "$session"
        }

        # Debug tmux sessions
        tdebug() {
          local session="debug"
          tmux new-session -d -s "$session" -n "monitor" 'htop'
          tmux split-window -t "$session" -h -l 50% 'btop'
          tmux new-window -t "$session" -n "system" 'watch -n 2 df -h'
          tmux split-window -t "$session" -h -l 50% 'watch -n 2 free -h 2>/dev/null || vm_stat'
          tmux select-window -t "$session:monitor"
          tmux attach-session -t "$session"
        }
        tdebug-full() {
          local session="debug-full"
          tmux new-session -d -s "$session" -n "processes" 'htop'
          tmux split-window -t "$session" -v -l 30% 'watch -n 2 "ps aux --sort=-%mem | head -15 2>/dev/null || ps aux -m | head -15"'
          tmux new-window -t "$session" -n "resources" 'btop'
          tmux new-window -t "$session" -n "disk" 'watch -n 5 df -h'
          tmux split-window -t "$session" -h -l 50% 'watch -n 5 "du -sh * 2>/dev/null | sort -hr | head -20"'
          tmux new-window -t "$session" -n "network" 'watch -n 2 "netstat -an | grep ESTABLISHED | head -20"'
          tmux select-window -t "$session:processes"
          tmux attach-session -t "$session"
        }
        tdebug-dev() {
          local name="$(_nvim_title)"
          local session="''${name//-/_}_debug"
          tmux new-session -d -s "$session" -n "editor" 'nvim .'
          tmux split-window -t "$session" -h -l 35% 'htop'
          tmux split-window -t "$session" -v -l 50%
          tmux new-window -t "$session" -n "monitor" 'btop'
          tmux select-window -t "$session:editor"
          tmux select-pane -t "$session" -L
          tmux attach-session -t "$session"
        }

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

        # Suffix aliases (open file by typing filename)
        alias -s md=bat
        alias -s json=bat
        alias -s yaml=bat
        alias -s yml=bat
        alias -s txt=bat
      ''
    ];
  };
}
