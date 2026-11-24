{
  description = "Cross-platform dotfiles with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pomo = {
      url = "github:pomopomo-app/pomo-zsh";
      flake = false;
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      nixgl,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      personas = import ./personas;

      overlays = [ ];

      pkgsFor =
        system:
        import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };

      commonHomeModules = [
        ./modules/home-manager
      ];

      # Build user from environment variables (with --impure) or fall back to briancorbin
      # Environment: NOMINIX_USER, NOMINIX_FULLNAME, NOMINIX_EMAIL
      envUser = builtins.getEnv "NOMINIX_USER";
      envFullName = builtins.getEnv "NOMINIX_FULLNAME";
      envEmail = builtins.getEnv "NOMINIX_EMAIL";

      defaultUser =
        personas.briancorbin
        // (
          if envUser != "" then
            {
              name = envUser;
              fullName = if envFullName != "" then envFullName else envUser;
              email = if envEmail != "" then envEmail else personas.briancorbin.email;
              # Only the persona's own user keeps its GitHub noreply address.
              githubEmail =
                if envUser == personas.briancorbin.name then personas.briancorbin.githubEmail else null;
            }
          else
            { }
        );

    in
    {
      # macOS (aarch64-darwin)
      darwinConfigurations."aarch64-darwin" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
          user = defaultUser;
        };
        modules = [
          ./hosts/aarch64-darwin
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs;
                user = defaultUser;
              };
              users.${defaultUser.name} = { pkgs, lib, ... }: {
                imports = commonHomeModules ++ [
                  ./modules/home-manager/packages/darwin.nix
                ];
                xdg.configFile."gh/config.yml".force = lib.mkForce true;
                xdg.configFile."atuin/config.toml".force = lib.mkForce true;
              };
            };
            users.users.${defaultUser.name}.home = "/Users/${defaultUser.name}";
          }
        ];
      };

      # Linux x86_64
      homeConfigurations."x86_64-linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "x86_64-linux";
        extraSpecialArgs = {
          inherit inputs;
          user = defaultUser;
          nixglPkgs = nixgl.packages.x86_64-linux;
        };
        modules = commonHomeModules ++ [
          ./hosts/x86_64-linux
          ./modules/home-manager/packages/linux.nix
        ];
      };

      # Linux aarch64
      homeConfigurations."aarch64-linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "aarch64-linux";
        extraSpecialArgs = {
          inherit inputs;
          user = defaultUser;
          nixglPkgs = nixgl.packages.aarch64-linux;
        };
        modules = commonHomeModules ++ [
          ./hosts/aarch64-linux
          ./modules/home-manager/packages/linux.nix
        ];
      };

      # Steam Deck (x86_64-linux with deck persona)
      homeConfigurations."steamdeck" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "x86_64-linux";
        extraSpecialArgs = {
          inherit inputs;
          user = personas.deck;
          nixglPkgs = nixgl.packages.x86_64-linux;
        };
        modules = commonHomeModules ++ [
          ./hosts/x86_64-linux
          ./modules/home-manager/packages/linux.nix
        ];
      };

      # WSL2 on Windows (x86_64-linux, CLI only)
      homeConfigurations."wsl" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "x86_64-linux";
        extraSpecialArgs = {
          inherit inputs;
          user = defaultUser;
          nixglPkgs = nixgl.packages.x86_64-linux;
        };
        modules = commonHomeModules ++ [
          ./hosts/wsl
          ./modules/home-manager/packages/linux.nix
        ];
      };

      # Dev shells for all systems
      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;

          # Shared with the Gradle toolchain registry in
          # home-manager/tools/gradle.nix — see there for why Temurin and why
          # this particular set of versions.
          jdks = import ./modules/jdks.nix pkgs;
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              nixfmt
            ];
          };

          # Java/Gradle repos: mutastic, mutastic-spike, mutastic-codex-try,
          # mutastic-gate-try, mutastic-gate-spike.
          #
          # Only the primary JDK goes on PATH here. Gradle finds the *other*
          # five through org.gradle.java.installations.paths in
          # ~/.gradle/gradle.properties, which home-manager writes and which
          # works machine-wide without a devShell — so this shell exists to
          # give `java`, `javac` and `mvn` a definite version, not to feed the
          # toolchain resolver.
          #
          # No gradle here on purpose. All five repos pin Gradle 9.2.1 through
          # ./gradlew, and nixpkgs has 8.14.6 — putting that on PATH would only
          # invite running the wrong one. The wrapper needs a JDK, not a Gradle.
          mutastic-java = pkgs.mkShell {
            packages = [
              jdks.primary
              pkgs.maven
            ];

            JAVA_HOME = jdks.primary.home;
          };

          # Rust repos: mutastic-rs and the rs-spike variants. No
          # rust-toolchain.toml anywhere and no native dependencies, so plain
          # stable is enough — nixpkgs has 1.99.0 against a 1.91 floor and
          # edition 2024.
          mutastic-rust = pkgs.mkShell {
            packages = with pkgs; [
              rustc
              cargo
              clippy
              rustfmt
            ];
          };

          # mutastic.io. package-lock.json and no engines field, so npm at
          # whatever nixpkgs pins (24.21.0) rather than a version guess.
          mutastic-node = pkgs.mkShell {
            packages = with pkgs; [ nodejs ];
          };
        }
      );
    };
}
