{ config, pkgs, lib, ... }:

{
  xdg.configFile."opencode/config.json" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      theme = "tokyonight";
    };
  };
}
