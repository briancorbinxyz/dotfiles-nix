{
  config,
  pkgs,
  lib,
  ...
}:

# opencode (installed via packages/default.nix).
#
# config.json is managed read-only from the store, which is fine because
# opencode keeps mutable state elsewhere — but it is also world-readable, so no
# secret may appear here. The llama.cpp API key is therefore referenced as
# {env:LLAMA_API_KEY}; opencode resolves an unset variable to an empty string,
# so a machine without the key still starts normally.
#
# Values come from nominix.llama so the server and this client cannot drift.
# Those options are readable on every host, including the ones where the server
# itself is disabled: only hosts/wsl sets nominix.llama.enable.

let
  llama = config.nominix.llama;
in
{
  xdg.configFile."opencode/config.json" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      theme = "tokyonight";

      # No top-level "model": this adds the local model as a choice (pick it with
      # /models) rather than displacing the default. Set
      # model = "llama/${llama.alias}" to make it the default.
      provider.llama = {
        # Installed into ~/.config/opencode/node_modules on first use, so the
        # first run with this provider needs network. Use @ai-sdk/openai for a
        # /v1/responses endpoint; llama.cpp speaks /v1/chat/completions.
        npm = "@ai-sdk/openai-compatible";
        name = "llama.cpp (${llama.clientHost})";
        options = {
          baseURL = "http://${llama.clientHost}:${toString llama.port}/v1";
          apiKey = "{env:LLAMA_API_KEY}";
        };
        models.${llama.alias} = {
          name = llama.alias;
          limit = {
            # Match the server's -c so opencode does not pack a prompt larger
            # than the context llama-server was started with.
            context = llama.contextSize;
            output = 32768;
          };
        };
      };
    };
  };
}
