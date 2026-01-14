{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 10000;
    escapeTime = 0;
    baseIndex = 1;
    keyMode = "vi";

    extraConfig = ''
      # Enable mouse support
      set -g mouse on

      # Better split bindings
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Vim-like pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes with vim keys
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Status bar styling
      set -g status-style bg=default,fg=white
      set -g status-left "#[fg=green]#S "
      set -g status-right "#[fg=cyan]%Y-%m-%d %H:%M"

      # Window styling
      set -g window-status-current-style fg=yellow,bold

      # Enable true color support
      set -ga terminal-overrides ",xterm-256color:Tc"
    '';

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
    ];
  };
}
