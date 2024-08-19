{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.amd;
in
{
  options.nyx.modules.system.amd = { 
    enable = mkEnableOption "AMD Env Vars"; 
  };
  config = mkIf cfg.enable {
    hardware.graphics = {
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        amdvlk
        driversi686Linux.amdvlk
      ]; 
    };
    environment.systemPackages = with pkgs; [
      radeontop 
      libllvm
      blender-hip
    ];
    environment.variables = {
      NIXOS_OZONE_WL = "1";
      __GLX_VENDOR_LIBRARY_NAME= "amd";
      LIBVA_DRIVER_NAME= "radeonsi"; # hardware acceleration
      __GL_VRR_ALLOWED="1";
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";
      CLUTTER_BACKEND = "wayland";
      WLR_RENDERER = "vulkan";    
    };
  };
}
