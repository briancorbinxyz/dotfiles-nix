{ config, pkgs, lib, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      theme = "tokyonight_night";
      style = "numbers,changes,header";
    };
    themes = {
      tokyonight_night = {
        src = pkgs.fetchFromGitHub {
          owner = "folke";
          repo = "tokyonight.nvim";
          rev = "v4.8.0";
          sha256 = "sha256-5QeY3EevOQzz5PHDW2CUVJ7N42TRQdh7QOF9PH1YxkU=";
        };
        file = "extras/sublime/tokyonight_night.tmTheme";
      };
    };
  };
}
