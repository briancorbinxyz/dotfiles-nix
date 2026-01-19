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

      # Debug layouts (prefix + D for debug menu)
      bind D display-menu -T "Debug Tools" \
        "htop (system monitor)"     h "split-window -h -l 50% htop" \
        "btop (resource monitor)"   b "split-window -h -l 50% btop" \
        "Full debug layout"         d "run-shell 'tmux split-window -h -l 40% htop; tmux split-window -v -l 50% \"watch -n 2 df -h\"'" \
        "Network watch"             n "split-window -h -l 50% 'watch -n 1 netstat -an | head -30'" \
        "Process tree"              p "split-window -h -l 50% 'watch -n 2 pstree -p'" \
        "Disk usage"                u "split-window -h -l 50% 'watch -n 5 df -h'"

      # Quick debug bindings
      bind M-h split-window -h -l 40% htop       # Alt+h for htop
      bind M-b split-window -h -l 40% btop       # Alt+b for btop
    '';

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
    ];
  };
}
