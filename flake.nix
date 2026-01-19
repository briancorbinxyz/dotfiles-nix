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
      url = "github:10xdevclub/pomo";
      flake = false;
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, nixgl, ... }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      personas = import ./personas;
      user = personas.briancorbin; # default persona

      overlays = [ ];

      # Linux overlays include nixGL for OpenGL wrapper support
      linuxOverlays = overlays ++ [ nixgl.overlay ];

      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = if builtins.match ".*-linux" system != null then linuxOverlays else overlays;
        config.allowUnfree = true;
      };

      commonHomeModules = [
        ./modules/home-manager
      ];

    in {
      # macOS (aarch64-darwin)
      darwinConfigurations."aarch64-darwin" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs user; };
        modules = [
          ./hosts/aarch64-darwin
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit inputs user; };
              users.briancorbin = { pkgs, lib, ... }: {
                imports = commonHomeModules ++ [
                  ./modules/home-manager/packages/darwin.nix
                ];
                xdg.configFile."gh/config.yml".force = lib.mkForce true;
                xdg.configFile."atuin/config.toml".force = lib.mkForce true;
              };
            };
            users.users.briancorbin.home = "/Users/briancorbin";
          }
        ];
      };

      # Linux x86_64
      homeConfigurations."x86_64-linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "x86_64-linux";
        extraSpecialArgs = { inherit inputs user; };
        modules = commonHomeModules ++ [
          ./hosts/x86_64-linux
          ./modules/home-manager/packages/linux.nix
        ];
      };

      # Linux aarch64
      homeConfigurations."aarch64-linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "aarch64-linux";
        extraSpecialArgs = { inherit inputs user; };
        modules = commonHomeModules ++ [
          ./hosts/aarch64-linux
          ./modules/home-manager/packages/linux.nix
        ];
      };

      # Steam Deck (x86_64-linux with deck persona)
      homeConfigurations."steamdeck" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "x86_64-linux";
        extraSpecialArgs = { inherit inputs; user = personas.deck; };
        modules = commonHomeModules ++ [
          ./hosts/x86_64-linux
          ./modules/home-manager/packages/linux.nix
        ];
      };

      # Dev shells for all systems
      devShells = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ git nixfmt ];
          };
        }
      );
    };
}