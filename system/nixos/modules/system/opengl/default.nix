{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.opengl;
in
{
  options.nyx.modules.system.opengl = { 
    enable = mkEnableOption "OpenGL Settings"; 
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