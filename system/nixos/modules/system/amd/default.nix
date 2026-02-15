{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.amd;
in
{
  options.nyx.modules.system.amd = { 
    enable = mkEnableOption "AMD Env Vars"; 
  };
  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "amdgpu" ];
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ]; 
    };
    environment.systemPackages = with pkgs; [
      radeontop       
      libva-utils     
      vulkan-tools
    ];
    environment.variables = {
      NIXOS_OZONE_WL = "1";           # Electron apps use Wayland
      CLUTTER_BACKEND = "wayland";
      LIBVA_DRIVER_NAME = "radeonsi"; # Force correct VAAPI driver for video decoding
    };
  };
}
