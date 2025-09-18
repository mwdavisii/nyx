{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.garbagecollection;
in
{
  options.nyx.modules.system.garbagecollection = { 
    enable = mkEnableOption "garbagecollection"; 
  };
  config = mkIf cfg.enable {
    nix.settings.auto-optimise-store = true;
  #Garbage colector
    nix.gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
    };

    system.autoUpgrade = {
        enable = true;
        channel = "https://nixos.org/channels/nixos-25.05";
    };
  };
}