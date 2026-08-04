{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = true;
      palette = "tokyo-night";

      # Tokyo Night (Night variant) — colors from folke/tokyonight.nvim.
      # Bright accent segments use fg_dark text; the dark os badge uses fg_light.
      palettes.tokyo-night = {
        os_bg = "#414868"; # terminal_black (neutral badge)
        dir_bg = "#7aa2f7"; # blue
        git_bg = "#9ece6a"; # green
        lang_bg = "#7dcfff"; # cyan
        duration_bg = "#e0af68"; # yellow
        time_bg = "#bb9af7"; # magenta
        error_fg = "#f7768e"; # red
        fg_dark = "#1a1b26"; # bg — near-black text for bright segments
        fg_light = "#c0caf5"; # fg — light text for the dark os badge
        gap_fg = "#565f89"; # comment — fill dashes
      };

      format = lib.concatStrings [
        "[](fg:os_bg)"
        "$os"
        "[](fg:os_bg bg:dir_bg)"
        "$directory"
        "[](fg:dir_bg bg:git_bg)"
        "$git_branch"
        "$git_status"
        "[](fg:git_bg)"
        "$fill"
        "[](fg:duration_bg)"
        "$cmd_duration"
        "[](fg:duration_bg bg:time_bg)"
        "$time"
        "[](fg:time_bg)"
        "$line_break"
        "$nodejs"
        "$bun"
        "$python"
        "$rust"
        "$terraform"
        "$nix_shell"
        "$container"
        "$battery"
        "$character"
      ];

      os = {
        disabled = false;
        style = "bg:os_bg fg:fg_light";
        format = "[ $symbol ]($style)";
        symbols = {
          Macos = "󰀵 ";
          Linux = "󰌽 ";
          Ubuntu = "󰕈 ";
          Arch = "󰣇 ";
          NixOS = " ";
        };
      };

      directory = {
        style = "bg:dir_bg fg:fg_dark bold";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncate_to_repo = true;
        read_only = " ";
        read_only_style = "bg:dir_bg fg:fg_dark";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
          "Code" = " ";
        };
      };

      git_branch = {
        symbol = " ";
        style = "bg:git_bg fg:fg_dark";
        format = "[ $symbol$branch ]($style)";
      };

      git_status = {
        style = "bg:git_bg fg:fg_dark";
        format = "[$all_status$ahead_behind ]($style)";
      };

      fill = {
        symbol = "─";
        style = "fg:gap_fg";
      };

      cmd_duration = {
        min_time = 3000;
        style = "bg:duration_bg fg:fg_dark";
        format = "[ $duration ⌛ ]($style)";
      };

      time = {
        disabled = false;
        time_format = "%T";
        style = "bg:time_bg fg:fg_dark";
        format = "[ $time ◐ ]($style)";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };

      line_break = {
        disabled = false;
      };

      nodejs = {
        symbol = " ";
        style = "fg:lang_bg";
        format = "via [$symbol($version )]($style)";
      };

      bun = {
        symbol = "🍞 ";
        style = "fg:lang_bg";
        format = "via [$symbol($version )]($style)";
      };

      python = {
        symbol = " ";
        style = "fg:lang_bg";
        format = "via [$symbol$pyenv_prefix($version )(\\($virtualenv\\) )]($style)";
      };

      rust = {
        symbol = " ";
        style = "fg:lang_bg";
        format = "via [$symbol($version )]($style)";
      };

      terraform = {
        symbol = "󱁢 ";
        style = "fg:lang_bg";
        format = "via [$symbol$workspace]($style) ";
      };

      nix_shell = {
        symbol = " ";
        style = "fg:lang_bg";
        format = "via [$symbol$state( \\($name\\))]($style) ";
      };

      container = {
        format = "[$symbol \\[$name\\]]($style) ";
      };

      battery = {
        format = "[$symbol$percentage]($style) ";
        display = [
          {
            threshold = 20;
            style = "bold red";
          }
        ];
      };
    };
  };
}
