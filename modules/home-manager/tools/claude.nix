{
  config,
  pkgs,
  lib,
  ...
}:

# Claude Code CLI (installed via packages/default.nix).
#
# IMPORTANT: ~/.claude/settings.json is an app-owned, READ-WRITE file. Claude
# Code persists state into it at runtime — /model, the /config theme picker and
# /plugin toggles all write it. Symlinking it into the read-only Nix store makes
# those writes fail ("Failed to set model: EACCES: permission denied, open
# '/nix/store/...-home-manager-files/.claude/settings.json'"). See codex.nix for
# the same trap.
#
# Unlike codex's config.toml, this file splits cleanly between keys this repo
# wants to own and keys the app owns, so rather than seeding once we MERGE on
# every activation: the declared keys below are deep-merged OVER the live file,
# so they stay declarative and reach every host, while anything Claude Code
# wrote itself (model, theme, ...) is preserved.
#
# Trade-off: a declared key changed through the UI is reverted on next rebuild.
# That is the point — to change one for good, change it in
# dotfiles/.claude/settings.json. Keys absent from that file are left alone.
#
# statusline-command.sh and the vendored skills stay as plain home.file store
# symlinks: Claude Code only ever reads those, so read-only is correct.
let
  declaredSettings = ../../../dotfiles/.claude/settings.json;
in
{
  home.file.".claude/statusline-command.sh" = {
    source = ../../../dotfiles/.claude/statusline-command.sh;
    executable = true;
  };

  # Global skills, vendored under dotfiles/.claude/skills/ and symlinked into
  # ~/.claude/skills/ so they're available in every project. Recursive keeps
  # each file individually linked (preserving the scripts' executable bits) and
  # leaves ~/.claude/skills/ writable for per-project or plugin-managed skills.
  home.file.".claude/skills/skill-creator" = {
    source = ../../../dotfiles/.claude/skills/skill-creator;
    recursive = true;
  };

  # After linkGeneration, not just writeBoundary: this generation no longer
  # declares settings.json, so linkGeneration is what removes the stale store
  # symlink. Ordering behind it means we always seed/merge onto its final
  # state instead of racing it for the same path.
  home.activation.mergeClaudeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    claudeSettings="${config.home.homeDirectory}/.claude/settings.json"

    run mkdir -p "$(dirname "$claudeSettings")"

    if [ -L "$claudeSettings" ]; then
      # The old home.file store symlink Claude Code cannot write to. Drop it so
      # a real, writable file can take its place.
      run rm -f "$claudeSettings"
    fi

    if [ ! -e "$claudeSettings" ]; then
      run install -m 0644 ${declaredSettings} "$claudeSettings"
    elif ! ${pkgs.jq}/bin/jq -e . "$claudeSettings" > /dev/null 2>&1; then
      # Unparseable (interrupted write, or a bad hand-edit). Merging garbage
      # would lose the declared config, so set it aside and re-seed instead.
      run mv "$claudeSettings" "$claudeSettings.corrupt"
      run install -m 0644 ${declaredSettings} "$claudeSettings"
    else
      # `*` deep-merges, so nested objects (statusLine, enabledPlugins) combine
      # key-by-key rather than the declared one replacing the live one whole.
      # Stage beside the target and rename, so a failed jq or an interrupted
      # rebuild can never leave truncated settings behind.
      staged="$claudeSettings.hm-new"
      if ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$claudeSettings" ${declaredSettings} > "$staged"; then
        chmod 0644 "$staged"
        run mv "$staged" "$claudeSettings"
      fi
      rm -f "$staged"
    fi
  '';
}
