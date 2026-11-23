{
  config,
  pkgs,
  lib,
  ...
}:

# direnv — automatically enters a directory's declared environment on `cd`, and
# unloads it on the way out. Paired with nix-direnv this means `nix develop`
# stops being something you have to remember: the flake's devShell is simply on
# PATH whenever you're inside the project.
#
# Each repo opts in with a .envrc (`use flake`) plus a one-time `direnv allow`.
# direnv refuses to source a .envrc it hasn't been explicitly allowed, which is
# what stops `git clone` from being arbitrary code execution.
{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;

    # nix-direnv replaces direnv's builtin `use flake` with a caching
    # implementation. Without it every `cd` re-evaluates the flake (slow), and
    # the resulting shell is an unrooted GC target, so `nix-collect-garbage`
    # deletes the toolchain you're sitting in. It caches the evaluation and
    # keeps a GC root per project.
    nix-direnv.enable = true;

    config.global = {
      # A devShell exports a lot of build-environment variables, and direnv
      # prints the whole diff on every load. Noisy enough to train you to
      # ignore the output entirely, which defeats the point.
      hide_env_diff = true;

      # Only grumble about a slow .envrc once the first uncached flake
      # evaluation is genuinely unreasonable, rather than on every cold start.
      warn_timeout = "30s";
    };
  };
}
