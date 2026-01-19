#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/briancorbinxyz/dotfiles-nix.git"
DOTFILES_DIR="$HOME/dotfiles-nix"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Keep sudo alive throughout the script
start_sudo_keepalive() {
    info "Requesting sudo access (password will be cached for the duration)..."
    sudo -v
    # Keep sudo timestamp fresh in the background
    while true; do
        sudo -n true
        sleep 50
    done &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null' EXIT
}

# Detect platform
detect_platform() {
    local os arch
    os="$(uname -s)"
    arch="$(uname -m)"

    case "$os" in
        Darwin)
            if [[ "$arch" == "arm64" ]]; then
                echo "aarch64-darwin"
            else
                echo "x86_64-darwin"
            fi
            ;;
        Linux)
            # Detect Steam Deck by username
            if [[ "$USER" == "deck" ]]; then
                echo "steamdeck"
            else
                echo "${arch}-linux"
            fi
            ;;
        *)
            error "Unsupported OS: $os"
            ;;
    esac
}

# Check if command exists
has() {
    command -v "$1" &>/dev/null
}

# Install Nix
install_nix() {
    if has nix; then
        success "Nix is already installed"
        return
    fi

    info "Installing Nix..."
    sh <(curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix) install

    # Source nix
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi

    success "Nix installed successfully"
}

# Clone dotfiles repository
clone_dotfiles() {
    if [[ -d "$DOTFILES_DIR" ]]; then
        warn "Dotfiles directory already exists at $DOTFILES_DIR"
        info "Pulling latest changes..."
        git -C "$DOTFILES_DIR" pull
    else
        info "Cloning dotfiles repository..."
        git clone "$REPO_URL" "$DOTFILES_DIR"
    fi
    success "Dotfiles ready at $DOTFILES_DIR"
}

# Run nix configuration
apply_config() {
    local platform="$1"

    info "Applying configuration for $platform..."

    case "$platform" in
        aarch64-darwin|x86_64-darwin)
            info "Running nix-darwin setup (requires sudo)..."
            sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake "$DOTFILES_DIR#aarch64-darwin"
            ;;
        steamdeck|*-linux)
            info "Running home-manager setup..."
            # --impure needed for nixGL GPU driver detection
            nix run home-manager/master -- switch -b backup --impure --flake "$DOTFILES_DIR#$platform"
            ;;
        *)
            error "Unknown platform: $platform"
            ;;
    esac

    success "Configuration applied successfully!"
}

main() {
    echo ""
    echo "================================================"
    echo "  dotfiles-nix installer"
    echo "================================================"
    echo ""

    local platform
    platform="$(detect_platform)"
    info "Detected platform: $platform"

    # macOS requires sudo for nix-darwin and Homebrew
    if [[ "$platform" == *-darwin ]]; then
        start_sudo_keepalive
    fi

    # Step 1: Install Nix
    install_nix

    # Step 2: Clone dotfiles
    clone_dotfiles

    # Step 3: Apply configuration
    apply_config "$platform"

    echo ""
    success "Installation complete!"
    echo ""
    echo "Please restart your shell or run:"
    echo "  exec \$SHELL"
    echo ""
    echo "For future updates, use:"
    echo "  nix-rebuild"
    echo ""
}

main "$@"
