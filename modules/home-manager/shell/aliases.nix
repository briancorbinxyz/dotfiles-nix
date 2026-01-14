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

  # Docker
  d = "docker";
  dc = "docker compose";
  dps = "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'";
  dex = "docker exec -it";

  # Navigation
  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../..";

  # Utility
  path = "echo $PATH | tr ':' '\\n'";
  myip = "curl -s ifconfig.me";
  weather = "curl wttr.in";

  # FZF + tools
  fzf = "fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'";
  vf = "nvim $(fd --type f | fzf --preview 'bat --color=always {}')";

  # Config editing
  zshrc = "nvim ~/.zshrc";
  reload = "source ~/.zshrc";

  # Markdown files open with bat
  ".md" = "bat";
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

  # Nix rebuild (auto-detects x86_64 or aarch64)
  nix-init = "nix run home-manager/master -- switch --flake ~/dotfiles-nix#$(uname -m)-linux";
  nix-rebuild = "home-manager switch --flake ~/dotfiles-nix#$(uname -m)-linux";
}
