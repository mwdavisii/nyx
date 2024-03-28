{ config, lib, pkgs, modulesPath, hostName, ... }:
  {
  #Garbage colector
    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
    };

    system.autoUpgrade = {
        enable = true;
        channel = "https://nixos.org/channels/nixos-23.11";
    };
  }