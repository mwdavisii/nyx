{ config, pkgs, ... }:

{
  imports = [
    ../../shared/system
    ]; 
  nyx = {
    modules = {
      user.home = ./home.nix;
    };
  };
}
