{ config, pkgs, ... }:

{

  nixpkgs = {
    config = {
      permittedInsecurePackages = [
          "nix-2.15.3"
      ];
      allowUnfree = true;
      allowBroken = true;
      allowUnsupportedSystem = true;
    };
  };
}
