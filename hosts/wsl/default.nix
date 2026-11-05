{
  config,
  pkgs,
  lib,
  user,
  ...
}:

{
  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = "24.05";
  };

  # WSL2 (x86_64): CLI only, Windows handles terminal, clipboard and browser
  nominix.wsl.enable = true;

  # Local inference on the RTX 5090, reachable over the tailnet only.
  # Prerequisites that live outside Nix are in README "llama.cpp server".
  nominix.llama = {
    enable = true;
    cudaCapabilities = [ "12.0" ]; # Blackwell (sm_120)
  };
}
