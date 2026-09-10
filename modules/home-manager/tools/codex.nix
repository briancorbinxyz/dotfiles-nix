{
  config,
  pkgs,
  lib,
  ...
}:

# OpenAI Codex CLI (installed via packages/default.nix).
#
# Codex reads its config from $CODEX_HOME/config.toml, which defaults to
# ~/.codex/config.toml — NOT ~/.config/codex/. Auth (`codex login`) is written
# separately to ~/.codex/auth.json.
#
# IMPORTANT: config.toml is an app-owned, READ-WRITE file. Codex persists state
# into it at runtime — most notably per-project trust (`[projects."..."]`), and
# the /theme and /model pickers. Symlinking it into the read-only Nix store
# makes those writes fail ("failed to persist config.toml"). So instead of
# managing it with home.file (a read-only store symlink), we SEED it once: on
# first activation we install a writable copy of the defaults below, then leave
# the file for Codex to own.
#
# Trade-off: because this is seed-once, editing the defaults here will NOT
# propagate to a machine that already has a ~/.codex/config.toml — update that
# file directly (or delete it and rebuild to re-seed).
let
  defaultConfig = pkgs.writeText "codex-config.toml" ''
    # Seeded by home-manager (modules/home-manager/tools/codex.nix).
    # Codex owns this file at runtime; edit it directly to change settings.

    # Leave `model` unset so Codex uses the best default for your account/plan.
    # Pin it here (e.g. model = "gpt-5.6") if you want a fixed model.

    # Balanced posture: Codex edits files and runs commands within the project
    # workspace freely, but asks before acting outside it or using the network.
    approval_policy = "on-request"
    sandbox_mode = "workspace-write"

    [tui]
    # Codex has no Tokyo Night theme; base16-ocean-dark is the closest bundled
    # match to the repo's palette. Run `/theme` in Codex to preview others.
    theme = "base16-ocean-dark"
  '';
in
{
  home.activation.seedCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    codexConfig="${config.home.homeDirectory}/.codex/config.toml"
    # A symlink here is the old read-only, store-managed config (Codex only ever
    # writes a real file), so drop it before seeding a writable copy.
    if [ -L "$codexConfig" ]; then
      run rm -f "$codexConfig"
    fi
    if [ ! -e "$codexConfig" ]; then
      run mkdir -p "$(dirname "$codexConfig")"
      run install -m 0644 ${defaultConfig} "$codexConfig"
    fi
  '';
}
