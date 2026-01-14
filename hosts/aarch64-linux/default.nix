{ config, pkgs, lib, user, ... }:

{
  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = "24.05";
  };

  # aarch64-linux specific settings
  # Lighter-weight for ARM devices with limited resources

  home.packages = with pkgs; [
    # Base packages from modules cover most needs
  ];

  # Reduced LSP support for resource-constrained devices
  programs.neovim.extraPackages = lib.mkForce (with pkgs; [
    lua-language-server
    pyright
    nil
    stylua
    shellcheck
  ]);
}
