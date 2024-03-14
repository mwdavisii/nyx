{
  inputs = {
    # Core
    nixpkgs.url             = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url    = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url      = "github:NixOS/nixpkgs/master";
    home-manager.url        = "github:nix-community/home-manager/release-23.11";
    nur.url                 = "github:nix-community/NUR";    
    # Secrets
    agenix.url = "github:ryantm/agenix";
    secrets = {
      url = "git+ssh://git@github.com/mwdavisii/nix-secrets.git";
      flake = false;
    };
    # MacOS
    nixpkgs-darwin.url      = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url        = "github:zhaofengli-wip/nix-homebrew";
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    # WSL
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #Droid
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # Other
    neovim-flake = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    ghostty-module.url = "github:clo4/ghostty-hm-module";
  };

  outputs = { self, ... }@inputs:
    with self.lib;
    let
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];
      foreachSystem = genAttrs systems;
      pkgsBySystem = foreachSystem (
        system:
        import inputs.nixpkgs {
          inherit system;
          config = import ./nix/config.nix;
          overlays = [
            #self.overlays."${system}"
            inputs.nix-on-droid.overlays.default
          ];
        }
      );
    in 
    rec {
      lib = import ./lib { inherit self inputs config; } // inputs.nixpkgs.lib;
      legacyPackages = pkgsBySystem;

      nixOnDroidConfigurations = mapAttrs' mkNixOnDroidConfiguration {
        nix-on-droid = {user = "droid";};
        default = {user = "droid";};
      };

      homeManagerConfigurations = mapAttrs' mkHome {
        mwdavisii = { };
      };

      darwinConfigurations = mapAttrs' mkDarwinConfiguration{
        mwdavis-workm1 = {system = "aarch64-darwin"; user = "mwdavisii";};
      };

      nixosConfigurations = mapAttrs' mkNixosWSLConfiguration {
        nixos = {};
      };
      
      top =
        let
          droidtop = genAttrs
            (builtins.attrNames inputs.self.nixOnDroidConfiguration)
            (attr: inputs.self.nixOnDroidConfiguration.${attr}.config.system.build.toplevel);
          nixtop = genAttrs
            (builtins.attrNames inputs.self.nixosConfigurations)
            (attr: inputs.self.nixosConfigurations.${attr}.config.system.build.toplevel);
          hometop = genAttrs
            (builtins.attrNames inputs.self.homeManagerConfigurations)
            (attr: inputs.self.homeManagerConfigurations.${attr}.activationPackage);
          darwintop = genAttrs
             (builtins.attrNames inputs.self.darwinConfigurations)
             (attr: inputs.self.darwinConfigurations.${attr}.system);
        in
        droidtop // nixtop // hometop // darwintop;
  };
}