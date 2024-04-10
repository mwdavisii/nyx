{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.nvidia;
in
{
  options.nyx.modules.system.nvidia = { 
    enable = mkEnableOption "AMD Env Vars"; 
  };
  config = mkIf cfg.enable {
    programs.hyprland.nvidiaPatches = true;
    environment.variables = {
      #NIXOS_OZONE_WL = "1";
      GBM_BACKEND= "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME= "nvidia";
      LIBVA_DRIVER_NAME= "nvidia"; # hardware acceleration
      __GL_VRR_ALLOWED="1";
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";
      CLUTTER_BACKEND = "wayland";
      WLR_RENDERER = "vulkan";
    };
  };
}