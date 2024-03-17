{ config, pkgs, ... }:

{
  imports = [../../shared/system.nix]; 
  nyx = {
    modules = {
      user.home = ./home.nix;
    };
  };
}
