{
  inputs = {
    # Core
    nixpkgs.url             = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url    = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url      = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url                 = "github:nix-community/NUR";    
    #hardware
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #Virtualization
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
          #  self.overlays."${system}"
            inputs.nix-on-droid.overlays.default
          ];
        }
      );
    in 
    rec {
      lib = import ./lib { inherit self inputs config; } // inputs.nixpkgs.lib;
      devShell = foreachSystem (system: import ./shell.nix { pkgs = pkgsBySystem."${system}"; });
      legacyPackages = pkgsBySystem;
      packages = foreachSystem (system: import ./nix/pkgs self system);
      overlay = foreachSystem (system: _final: _prev: self.packages."${system}");
      overlays = foreachSystem (
        system: with inputs; let
          ovs = attrValues (import ./nix/overlays self);
        in
        [
          (self.overlay."${system}")
          (nur.overlay)
          # (_:_: { inherit (eww.packages."${system}") eww; })
        ] ++ ovs
      );
      nixOnDroidConfigurations = mapAttrs' mkNixOnDroidConfiguration {
        nix-on-droid = {user = "droid";};
        default = {user = "droid";};
      };

      homeManagerConfigurations = mapAttrs' mkHome {
        mwdavisii = { };
      };

      darwinConfigurations = mapAttrs' mkNixSystemConfiguration {
        mwdavis-workm1 = {system = "aarch64-darwin"; user = "mwdavisii"; buildTarget="darwin";}; #macbook
      };

      nixosConfigurations = mapAttrs' mkNixSystemConfiguration {
        mwdavis-workm1 = {system = "aarch64-darwin"; user = "mwdavisii"; buildTarget="darwin";}; #macbook
        nixos = {user="nixos"; hostname ="nixos"; buildTarget="wsl";}; #WSL
        personal = {user="nixos"; hostname ="personal"; buildTarget="wsl";}; #WSL
        work = {user="nixos"; hostname = "work"; buildTarget="wsl";}; #WSL
        worklt = {hostname = "worklt"; user ="mwdavisii"; buildTarget="nixos";}; #Work Laptop (Host OS)
        virtualbox = {hostname = "virtualBoxOVA"; user ="mwdavisii"; buildTarget="vm";}; #nix build .#nixosConfigurations.virtualbox.config.system.build.isoImage
        livecd = {hostname = "worklt"; user ="mwdavisii"; buildTarget="iso";}; #nix build .#nixosConfigurations.livecd.config.system.build.isoImage
      };
      
      top =
        let
          livecd = (builtins.attrNames inputs.self.nixosConfigurations)
            #(attr: inputs.self.nixosConfigurations.${attr}.config.system.build.isoImage);
            (attr: inputs.self.nixosConfigurations.${attr}.livecd.config.formats.iso);
          droidtop = genAttrs
            (builtins.attrNames inputs.self.nixOnDroidConfigurations)
            (attr: inputs.self.nixOnDroidConfigurations.${attr}.config.system.build.toplevel);
          nixtop = genAttrs
            (builtins.attrNames inputs.self.nixosConfigurations)
            (attr: inputs.self.nixosConfigurations.${attr}.config.system.build.toplevel);
          hometop = genAttrs
            (builtins.attrNames inputs.self.homeManagerConfigurations)
            (attr: inputs.self.homeManagerConfigurations.${attr}.activationPackage);
          darwintop = genAttrs
             (builtins.attrNames inputs.self.darwinConfigurations)
             (attr: inputs.self.darwinConfigurations.${attr}.system);
          vmtop = genAttrs
            (builtins.attrNames inputs.self.nixosConfigurations)
            (attr: inputs.self.nixosConfigurations.${attr}.config.system.build.toplevel);
        in
        droidtop // nixtop // hometop // darwintop // vmtop;
  };
}
