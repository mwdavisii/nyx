{ config, pkgs, ... }:


{
  
  nyx = {
    modules = {
      user.home = ../../../../home/darwin/home.nix;
    };
  };
}