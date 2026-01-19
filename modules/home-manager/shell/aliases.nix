{ pkgs, lib, ... }:

{
  # Modern tool replacements
  cat = "bat";
  ls = "lsd";
  ll = "lsd -la";
  lt = "lsd --tree";
  tree = "lsd --tree";
  vi = "nvim";
  vim = "nvim";

  # Terraform
  tf = "terraform";

  # Git shortcuts
  g = "git";
  ga = "git add";
  gc = "git commit";
  gp = "git push";
  gpl = "git pull";
  gst = "git status";
  glog = "git log --oneline --graph --decorate -20";
  uncommit = "git reset --soft HEAD~1";
  amend = "git commit --amend --no-edit";
  wip = "git add -A && git commit -m 'WIP'";

  # Tmux
  tm = "tmux";
  tma = "tmux attach-session";
  tmat = "tmux attach-session -t";
  tmks = "tmux kill-session -a";
  tml = "tmux list-sessions";
  tmn = "tmux new-session";
  tmns = "tmux new -s";
  tms = "tmux new-session -s";

  # System monitoring
  top = "htop";
  sys = "btop";  # Podman
  p = "podman";
  pc = "podman compose";
  pps = "podman ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'";
  pex = "podman exec -it";

  # Network
  di = "dig";
  di4 = "dig +short -4";
  di6 = "dig +short -6";
  diga = "dig +all ANY";
  digs = "dig +short";
  digg = "dig @8.8.8.8 +nocmd any +multiline +noall +answer";

  # Navigation
  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../..";

  # Utility
  path = "echo $PATH | tr ':' '\\n'";
  myip = "curl -s ifconfig.me";
  weather = "curl wttr.in";

  # fd (modern find)
  find = "fd";
  fda = "fd --absolute-path";
  fdc = "fd --ignore-case";
  fdd = "fd --list-details";
  fde = "fd --extension";
  fdf = "fd --follow";
  fdh = "fd --hidden";
  fdn = "fd --glob";
  fdo = "fd --owner";
  fds = "fd --size";
  fdu = "fd --exclude";
  fdx = "fd --exec";

  # FZF + tools
  fzf = "fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'";
  vfd = "nvim $(fd --type f | fzf --preview 'bat --color=always {}')";

  # AI coding assistants
  o = "opencode";

  # Config editing
  zshrc = "nvim ~/.zshrc";
  reload = "source ~/.zshrc";
} // lib.optionalAttrs pkgs.stdenv.isDarwin {
  # macOS-specific aliases
  copy = "pbcopy";
  paste = "pbpaste";
  ports = "lsof -i -P -n | grep LISTEN";

  # Nix rebuild
  nix-init = "sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake ~/dotfiles-nix#aarch64-darwin";
  nix-rebuild = "sudo darwin-rebuild switch --flake ~/dotfiles-nix#aarch64-darwin";
} // lib.optionalAttrs pkgs.stdenv.isLinux {
  # Linux-specific aliases
  copy = "xclip -selection clipboard";
  paste = "xclip -selection clipboard -o";
  ports = "ss -tuln";

  # OpenGL wrapper for GUI apps on non-NixOS
  ghostty = "nixGL ghostty";

  # Nix rebuild (auto-detects architecture and Steam Deck)
  # --impure needed for nixGL GPU driver detection
  nix-init = "nix run home-manager/master -- switch --impure --flake ~/dotfiles-nix#$([ \"$USER\" = \"deck\" ] && echo steamdeck || echo $(uname -m)-linux)";
  nix-rebuild = "home-manager switch --impure --flake ~/dotfiles-nix#$([ \"$USER\" = \"deck\" ] && echo steamdeck || echo $(uname -m)-linux)";
}
