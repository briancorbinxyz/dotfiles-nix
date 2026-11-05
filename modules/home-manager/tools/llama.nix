{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

# llama.cpp server (llama-server), built by Nix with CUDA and bound to the
# Tailscale address so that only tailnet devices can reach it. The API key is a
# second lock rather than the only one, which is why no firewall rule is needed.
#
# Three things Nix deliberately does NOT own here (see README "llama.cpp server"):
#
#   1. tailscaled. It needs root and a system-level systemd unit to create the
#      TUN device, and home-manager can only write user units. Install it the
#      Ubuntu way inside WSL. (Userspace-networking mode needs no root but gives
#      no tailnet IP to bind to, so it does not help.)
#   2. The model weights. `-hf` downloads GGUFs at runtime into ~/.cache/llama.cpp
#      — inside WSL that is the Ubuntu filesystem, so a model already downloaded
#      on the Windows side is fetched again.
#   3. The API key. The Nix store is world-readable, so the key is generated on
#      the machine at first activation and handed over by file, never inlined.

let
  cfg = config.nominix.llama;

  # cudaCapabilities is a *nixpkgs config* setting rather than a package
  # argument, so narrowing the build to the one GPU architecture this box
  # actually has means re-importing nixpkgs instead of overriding the
  # derivation. Worth it: the default list is nine architectures
  # (7.5 … 12.1) and device-code compilation scales with it.
  pkgsCuda = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    config = {
      allowUnfree = true; # CUDA is unfree-but-redistributable
      cudaCapabilities = cfg.cudaCapabilities;
      cudaForwardCompat = false; # skip PTX for unreleased archs
    };
  };

  basePackage =
    if cfg.package != null then
      cfg.package
    else if cfg.cuda then
      pkgsCuda.llama-cpp.override { cudaSupport = true; }
    else
      pkgs.llama-cpp;

  # WSL2 exposes the Windows NVIDIA driver here and nowhere else: there is no
  # /run/opengl-driver/lib (that is NixOS) and no /proc/driver/nvidia, so nixGL
  # cannot detect a driver either. A Nix-built CUDA binary finds the real
  # libcuda.so.1 only if this directory is on LD_LIBRARY_PATH — which is
  # searched before DT_RUNPATH, so the cudart stub in the store does not win.
  driverLibs = "/usr/lib/wsl/lib";

  # Scope the host-library exposure to the llama.cpp binaries rather than
  # exporting LD_LIBRARY_PATH session-wide, where every other Nix binary would
  # start picking up Ubuntu's libraries.
  llamaPackage =
    if config.nominix.wsl.enable then
      pkgs.symlinkJoin {
        name = "llama-cpp-wsl-${basePackage.version}";
        paths = [ basePackage ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          for bin in "$out"/bin/*; do
            wrapProgram "$bin" --prefix LD_LIBRARY_PATH : "${driverLibs}"
          done
        '';
      }
    else
      basePackage;

  genApiKey = pkgs.writeShellApplication {
    name = "nominix-gen-llama-api-key";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      keyFile="$1"
      mkdir -p "$(dirname "$keyFile")"
      umask 077
      head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' > "$keyFile"
      chmod 0600 "$keyFile"
      echo "llama: generated an API key at $keyFile"
      echo "llama: copy it to the client with: cat $keyFile"
    '';
  };

  serve = pkgs.writeShellApplication {
    name = "llama-serve";
    runtimeInputs = [
      llamaPackage
      pkgs.coreutils
    ];
    text = ''
      host="${cfg.host}"

      if [ "$host" = "tailscale" ]; then
        # The tailnet IP is resolved at run time, not build time: it is assigned
        # by the control plane and can change. On a cold boot this can also run
        # before tailscaled has finished coming up, hence the wait.
        ts_bin=""
        for candidate in /usr/bin/tailscale /usr/local/bin/tailscale; do
          if [ -x "$candidate" ]; then
            ts_bin="$candidate"
            break
          fi
        done
        if [ -z "$ts_bin" ] && command -v tailscale > /dev/null 2>&1; then
          ts_bin="$(command -v tailscale)"
        fi
        if [ -z "$ts_bin" ]; then
          echo "llama-serve: tailscale not found; install it inside WSL (see README)" >&2
          exit 1
        fi

        host=""
        attempt=0
        while [ "$attempt" -lt 30 ]; do
          host="$("$ts_bin" ip -4 2> /dev/null || true)"
          if [ -n "$host" ]; then
            break
          fi
          attempt=$((attempt + 1))
          sleep 2
        done
        if [ -z "$host" ]; then
          echo "llama-serve: no Tailscale IPv4 address after 60s; is tailscaled up?" >&2
          exit 1
        fi
      fi

      # --api-key-file throws if the file is missing, so only pass it when the
      # key is actually there; the tailnet binding is still the primary lock.
      keyArgs=()
      if [ -r "${cfg.apiKeyFile}" ]; then
        keyArgs=(--api-key-file "${cfg.apiKeyFile}")
      else
        echo "llama-serve: no API key at ${cfg.apiKeyFile}; serving the tailnet unauthenticated" >&2
      fi

      echo "llama-serve: ${cfg.alias} on $host:${toString cfg.port}"

      # "$@" comes last so ad-hoc flags win: llama.cpp parses arguments in
      # order and the last occurrence of an option takes effect.
      exec llama-server \
        -hf "${cfg.model}" \
        --alias "${cfg.alias}" \
        -ngl ${toString cfg.gpuLayers} \
        -c ${toString cfg.contextSize} \
        --host "$host" \
        --port ${toString cfg.port} \
        ${lib.escapeShellArgs cfg.extraFlags} \
        "''${keyArgs[@]}" \
        "$@"
    '';
  };
in
{
  options.nominix.llama = {
    enable = lib.mkEnableOption "llama.cpp server";

    cuda = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Build llama.cpp with CUDA. This is a long local compile — nixpkgs' binary
        cache has no CUDA variant — so expect tens of minutes on first rebuild.
      '';
    };

    cudaCapabilities = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "12.0" ];
      example = [ "8.9" ];
      description = ''
        CUDA compute capabilities to generate kernels for. One entry keeps the
        build as short as possible; "12.0" is Blackwell (RTX 50-series),
        "8.9" Ada (RTX 40-series), "8.6" Ampere (RTX 30-series).
      '';
    };

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      example = lib.literalExpression "pkgs.llama-cpp";
      description = ''
        Use this llama.cpp package instead of building one. Set it to escape the
        CUDA build — e.g. to a package wrapping an out-of-band `~/llama.cpp`
        build — without touching the rest of this module.
      '';
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = "unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q5_K_S";
      description = "Hugging Face repo[:quant] passed to -hf, downloaded at run time.";
    };

    alias = lib.mkOption {
      type = lib.types.str;
      default = "qwen3.6-35b";
      description = "Model name the server reports to API clients.";
    };

    gpuLayers = lib.mkOption {
      type = lib.types.int;
      default = 99;
      description = "Layers to offload to the GPU (-ngl); 99 means all of them.";
    };

    contextSize = lib.mkOption {
      type = lib.types.int;
      default = 131072;
      description = "Context window in tokens (-c).";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "tailscale";
      example = "127.0.0.1";
      description = ''
        Address to bind. The literal "tailscale" resolves `tailscale ip -4` at
        start-up, which keeps the server off every other interface.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to listen on.";
    };

    clientHost = lib.mkOption {
      type = lib.types.str;
      default = "llama-5090";
      description = ''
        MagicDNS name clients dial to reach this server, i.e. the Tailscale
        machine name. Only clients use it — the server itself binds to the
        address, not the name — so it is read on every host, including those
        where this module is disabled (see tools/opencode.nix). Rename the node
        with `tailscale set --hostname=...` and change this to match.
      '';
    };

    apiKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/nominix/llama-api-key";
      description = ''
        File holding the API key, one per line. Generated with mode 0600 on first
        activation if absent, and never placed in the world-readable Nix store.
      '';
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "-fa"
        "on"
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
        "--jinja"
        "--temp"
        "0.6"
        "--top-p"
        "0.95"
        "--top-k"
        "20"
        "--min-p"
        "0"
        "--sleep-idle-seconds"
        "900"
      ];
      description = ''
        Remaining llama-server flags: flash attention, a quantised KV cache so a
        131k context fits in VRAM, the model's chat template, its recommended
        sampling values, and idle sleep to release VRAM after 15 minutes.
      '';
    };

    service.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Run llama-server as a systemd user service. Needs systemd inside WSL
        ([boot] systemd=true) and, to start without a login,
        `loginctl enable-linger $USER`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # llamaPackage too, so llama-bench and llama-cli are on PATH with the same
    # driver wrapping as the server.
    home.packages = [
      serve
      llamaPackage
    ];

    # Secrets cannot come from the store, so the key is seeded on the machine —
    # the same seed-once shape as tools/codex.nix, and never overwritten.
    home.activation.seedLlamaApiKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e "${cfg.apiKeyFile}" ]; then
        run ${genApiKey}/bin/nominix-gen-llama-api-key "${cfg.apiKeyFile}"
      fi
    '';

    systemd.user.services.llama-server = lib.mkIf cfg.service.enable {
      Unit = {
        Description = "llama.cpp server (${cfg.alias})";
        Documentation = "https://github.com/ggml-org/llama.cpp";
      };

      Service = {
        ExecStart = "${serve}/bin/llama-serve";
        # A first start downloads the whole GGUF, and a tailnet hiccup should not
        # be fatal; the wrapper waits for an address before binding.
        Restart = "on-failure";
        RestartSec = 10;
      };

      # No After= on default.target: WantedBy already orders this after it, and
      # naming both would be a cycle.
      Install.WantedBy = [ "default.target" ];
    };

    programs.zsh.shellAliases = {
      llama-health = "curl -fsS http://$(tailscale ip -4):${toString cfg.port}/health";
      llama-key = "cat ${cfg.apiKeyFile}";
    }
    // lib.optionalAttrs cfg.service.enable {
      llama-up = "systemctl --user start llama-server";
      llama-down = "systemctl --user stop llama-server";
      llama-status = "systemctl --user status llama-server";
      llama-log = "journalctl --user -u llama-server -f";
    };
  };
}
