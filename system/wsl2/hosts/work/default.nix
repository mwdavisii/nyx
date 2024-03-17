{ config, pkgs, ... }:

{
  imports = [../../common/system.nix]; 
  nyx = {
    modules = {
      user.home = ./home.nix;
    };
  };
}
