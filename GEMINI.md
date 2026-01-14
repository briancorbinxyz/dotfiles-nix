# Project Overview

This is a cross-platform dotfiles repository managed with [Nix](https://nixos.org/), [home-manager](https://github.com/nix-community/home-manager), and [Nix Flakes](https://nixos.wiki/wiki/Flakes). It provides a consistent development environment across macOS (Apple Silicon) and Linux (x86_64, aarch64).

The core idea is to define packages, configurations, and dotfiles declaratively in the Nix language. This makes the setup reproducible, portable, and easy to manage.

**Key Technologies:**

*   **Nix:** The package manager and language used to define the entire environment.
*   **home-manager:** A Nix-based tool to manage a user's dotfiles and environment.
*   **nix-darwin:** A Nix module system for managing macOS configuration.
*   **Flakes:** The new, improved way to manage Nix dependencies and package outputs.

**Architecture:**

The repository is structured into a few key directories:

*   `flake.nix`: The central entry point that defines inputs (like `nixpkgs`, `home-manager`) and outputs (the different system configurations).
*   `hosts/`: Contains host-specific configurations. This is where the main `nix-darwin` and `home-manager` configurations are defined for each supported platform.
*   `modules/`: Contains shared, modularized configurations that are imported by the different hosts. This promotes code reuse. For example, the `neovim.nix` module sets up Neovim with its dependencies.
*   `dotfiles/`: Contains the raw dotfiles (e.g., `init.lua` for Neovim) that are linked into the correct locations by `home-manager`.

# Building and Running

The commands to activate the configuration are different for the first-time setup and subsequent updates.

## macOS (Apple Silicon)

**First-time setup:**

```bash
nix run nix-darwin -- switch --flake ~/dotfiles-nix#aarch64-darwin
```

**Subsequent updates:**

```bash
darwin-rebuild switch --flake ~/dotfiles-nix#aarch64-darwin
```

## Linux (x86_64)

**First-time setup:**

```bash
nix run home-manager/master -- switch --flake ~/dotfiles-nix#x86_64-linux
```

**Subsequent updates:**

```bash
home-manager switch --flake ~/dotfiles-nix#x86_64-linux
```

## Linux (aarch64)

**First-time setup:**

```bash
nix run home-manager/master -- switch --flake ~/dotfiles-nix#aarch64-linux
```

**Subsequent updates:**

```bash
home-manager switch --flake ~/dotfiles-nix#aarch64-linux
```

# Development Conventions

*   **Declarative Configuration:** All system and application configuration should be managed through Nix files in this repository. Avoid manual, imperative changes to dotfiles.
*   **Modularity:** For new applications or configurations, create a new module in the `modules/` directory and import it into the appropriate host configurations. This keeps the setup clean and organized.
*   **Secrets:** There is no explicit handling of secrets in this repository. Sensitive information should not be committed.
*   **Formatting:** The `flake.nix` provides a `devShell` that includes `nixfmt-classic`. It is recommended to format Nix files with it.
    ```bash
    nix develop
    nixfmt .
    ```
