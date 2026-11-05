# dotfiles-nix

Cross-platform dotfiles managed with Nix flakes and home-manager.

## Supported Platforms

| Configuration | Architecture | Use Case |
|--------------|--------------|----------|
| `aarch64-darwin` | Apple Silicon Mac | nix-darwin + home-manager + Homebrew |
| `x86_64-linux` | Intel/AMD Linux | standalone home-manager |
| `steamdeck` | Steam Deck | standalone home-manager with `deck` persona (see [Steam Deck](#steam-deck)) |
| `aarch64-linux` | ARM Linux (Pi, etc.) | standalone home-manager |
| `wsl` | WSL2 on Windows (x86_64) | standalone home-manager, CLI only (see [WSL](#wsl)) |

## Installation

> **Warning**: Installation requires `sudo` access. The install script and nix-darwin commands modify system-level configurations.

### Quick Install (recommended)

Run the bootstrap script - it handles everything (Nix, cloning, configuration):

```bash
curl -fsSL https://raw.githubusercontent.com/briancorbinxyz/dotfiles-nix/main/install.sh | bash
```

Or, if you prefer to inspect the script first:

```bash
curl -fsSL https://raw.githubusercontent.com/briancorbinxyz/dotfiles-nix/main/install.sh -o install.sh
less install.sh  # review the script
bash install.sh
```

### Manual Install

1. Install [Nix](https://nixos.org/):
```bash
sh <(curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix) install
```

2. Clone and apply:
```bash
git clone https://github.com/briancorbinxyz/dotfiles-nix.git ~/dotfiles-nix
cd ~/dotfiles-nix
# Then run nix-init command for your platform (see Usage below)
```

## Usage

After initial setup, use the cross-platform aliases:
```bash
nix-init      # First time setup
nix-rebuild   # Subsequent updates
```

### Manual Commands

**macOS (nix-darwin)**:
```bash
# First time (requires sudo and experimental features)
sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/dotfiles-nix#aarch64-darwin

# Subsequent updates
sudo darwin-rebuild switch --flake ~/dotfiles-nix#aarch64-darwin
```

**Linux (standalone home-manager)** - auto-detects architecture:
```bash
# First time
nix run home-manager/master -- switch --flake ~/dotfiles-nix#$(uname -m)-linux

# Subsequent updates
home-manager switch --flake ~/dotfiles-nix#$(uname -m)-linux
```

### Steam Deck

SteamOS uses an immutable filesystem, so additional steps are required before installing Nix:

```bash
# 1. Disable read-only mode
sudo steamos-readonly disable

# 2. Create Nix directories (must be root-owned)
sudo mkdir -p /nix /nix/var /nix/var/nix /nix/var/nix/db /nix/var/nix/gcroots /nix/var/nix/profiles /nix/var/nix/temproots /nix/var/nix/userpool /nix/var/log/nix /nix/var/log/nix/drvs
sudo chown -R root:root /nix

# 3. Install Nix
sh <(curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix) install

# 4. Re-enable read-only mode
sudo steamos-readonly enable
```

Then apply the Steam Deck configuration (uses `deck` user persona):

```bash
# First time
nix run home-manager/master -- switch --flake ~/dotfiles-nix#steamdeck

# Subsequent updates
home-manager switch --flake ~/dotfiles-nix#steamdeck
```

> **Note**: SteamOS updates may reset the filesystem. You may need to repeat these steps after major system updates.

### WSL

The `wsl` configuration is the x86_64 Linux setup without the Linux GUI side: no Alacritty, Ghostty, Obsidian, Dropbox, nixGL, Nerd Fonts or Ollama, since Windows provides the terminal, fonts and GUI apps. `copy`/`paste` use the Windows clipboard, `open` runs `explorer.exe`, and `BROWSER` is `wslview` (or `explorer.exe` if wslu is missing).

1. From an admin PowerShell, enable WSL and install Ubuntu (enable virtualization in your BIOS first if `wsl --status` asks for it):
```powershell
wsl --install --no-distribution
wsl --install Ubuntu
```

2. Inside Ubuntu, run the [Quick Install](#quick-install-recommended). It detects WSL and applies `#wsl`. Ubuntu on WSL runs systemd by default, which the Nix daemon needs.

3. On Windows, install [MesloLGS Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) and set it as the Ubuntu profile's font in Windows Terminal, so the prompt glyphs render.

```bash
# First time
nix run home-manager/master -- switch --impure --flake ~/dotfiles-nix#wsl

# Subsequent updates
home-manager switch --impure --flake ~/dotfiles-nix#wsl
```

### llama.cpp server (WSL + RTX 5090)

The `wsl` host enables `nominix.llama` (`modules/home-manager/tools/llama.nix`): it builds `llama-cpp` with CUDA for Blackwell (sm_120) only, wraps the binaries so they find the Windows GPU driver, and runs `llama-server` as a systemd user service bound to the Tailscale address. Binding to the tailnet is what removes the need for a Windows firewall rule, and makes the API key a second lock rather than the only one.

Three prerequisites cannot be declared by home-manager — they need root or a secret:

1. **systemd inside WSL** (user services need it; recent Ubuntu images have it on):
   ```bash
   cat /etc/wsl.conf        # want: [boot] systemd=true
   ```
   If those lines are missing, add them, run `wsl --shutdown` from Windows, and reopen Ubuntu.

2. **Tailscale**, which needs root for the TUN device and a *system* systemd unit, so it is installed the Ubuntu way rather than with Nix:
   ```bash
   curl -fsSL https://tailscale.com/install.sh | sh
   sudo tailscale up --hostname=llama-5090
   ```

3. **Lingering**, so the service starts with the distro rather than with your first login:
   ```bash
   loginctl enable-linger "$USER"
   ```

Then rebuild. The first run compiles llama.cpp's CUDA kernels locally — nixpkgs' binary cache has no CUDA variant — so expect tens of minutes:

```bash
nix-rebuild              # compiles the CUDA kernels, then starts the service (sd-switch)
exec zsh                 # pick up the new llama-* aliases
llama-key                # the API key, generated at mode 0600 on first activation
llama-log                # follow it: the first start downloads the GGUF
llama-health             # curl /health on the tailnet address
llama-up / llama-down    # start or stop it by hand
```

From the Mac, or any other tailnet device:

```bash
curl http://llama-5090:8080/health
```

Worth knowing:

- **Models download again.** `-hf` saves GGUFs to `~/.cache/llama.cpp` inside Ubuntu, not to the Windows cache, so a model already pulled on the Windows side is fetched a second time.
- **A sleeping PC leaves the tailnet.** Set the Windows power plan to never sleep while plugged in.
- **Lingering is not auto-start.** `enable-linger` keeps the service running with no login session, but only while the WSL VM is up; it does not launch WSL when Windows boots. For that, add a logon scheduled task running `wsl -d Ubuntu -e true`, and remember `wsl --shutdown` stops everything regardless.
- **The GPU driver comes from Windows.** Nix-built CUDA binaries find `libcuda.so.1` only through `/usr/lib/wsl/lib`, so the module puts that on `LD_LIBRARY_PATH` for the llama.cpp binaries alone. `nixGL` cannot help here: it detects drivers through `/proc/driver/nvidia`, which WSL does not have.
- **The server sleeps when idle** after 15 minutes (`--sleep-idle-seconds 900`), releasing VRAM; the next request wakes it, so that one is slow.
- **Flags live in `extraFlags`** on `nominix.llama`, and `llama-serve` passes ad-hoc arguments through to `llama-server`: `llama-serve --port 9090 -c 65536`. Running `llama-serve` in tmux is the easy way to iterate on flags before leaning on the service.
- **To stop Nix building llama.cpp**, set `nominix.llama.package` to a package of your own (e.g. one wrapping an out-of-band `~/llama.cpp` build) or `nominix.llama.cuda = false` for a CPU build; everything else in the module stays the same.

## Structure

```
dotfiles-nix/
├── flake.nix                    # Main flake entry point
├── hosts/                       # Host-specific configurations
│   ├── aarch64-darwin/          # macOS Apple Silicon
│   ├── x86_64-linux/            # Linux x86_64 (+ Steam Deck)
│   ├── aarch64-linux/           # Linux ARM64
│   └── wsl/                     # WSL2 on Windows (CLI only)
├── personas/                    # User personas (briancorbin, deck, etc.)
├── modules/home-manager/        # Shared home-manager modules
│   ├── shell/                   # Zsh, aliases
│   ├── editors/                 # Neovim
│   ├── terminal/                # Alacritty, Ghostty, tmux
│   ├── tools/                   # Git, atuin, bat, fzf
│   └── packages/                # Base + platform-specific packages
└── dotfiles/                    # Raw config files (nvim, etc.)
```

## What's Managed

### Via Nix (all platforms)
- Shell tools: atuin, bat, fd, fzf, git, gh, jq, lsd, pay-respects, ripgrep, tmux, yq, zoxide
- Development: grpcurl, httpie, websocat, hyperfine, bitwarden-cli
- Editor: Neovim with LSP dependencies

### Via Homebrew (macOS only)
- GUI apps: Alacritty, Ghostty, Docker Desktop, VS Code, Obsidian, etc.
- CLI tools: asdf, gemini-cli, mas, node, pixi, pyenv, rust, terraform
- Fonts: MesloLGS Nerd Font

### Dotfiles (managed via home-manager)
- Zsh with oh-my-zsh and powerlevel10k
- Neovim (LazyVim configuration)
- Alacritty/Ghostty terminal configs
- Git configuration
- tmux configuration

### Notable Aliases

| Alias | Description |
|-------|-------------|
| `brain-sync` | Sync Obsidian vault (Brain) to website repo's `content/` |
| `brain-publish` | Sync, commit, and push to deploy the website |
| `nix-rebuild` | Rebuild nix configuration for current platform |
| `c` / `cr` / `cx` | Claude Code shortcuts |
| `llama-up` / `llama-log` / `llama-health` | Control the llama.cpp server on WSL |
