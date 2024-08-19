{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.acceleratedgraphics;
in
{
  options.nyx.modules.system.acceleratedgraphics = { 
    enable = mkEnableOption "Accelerated Graphics Settings"; 
  };

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        amdvlk
      ]; 
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };
}