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
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, ... }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      user = {
        name = "briancorbin";
        fullName = "Brian Corbin";
        email = "me@briancorbin.co.uk";
      };

      overlays = [ ];

      pkgsFor = system: import nixpkgs {
        inherit system overlays;
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
              users.${user.name} = { ... }: {
                imports = commonHomeModules ++ [
                  ./modules/home-manager/packages/darwin.nix
                ];
              };
              extraSpecialArgs = { inherit inputs user; };
            };
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

      # Dev shells for all systems
      devShells = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ git nixfmt-classic ];
          };
        }
      );
    };
}
