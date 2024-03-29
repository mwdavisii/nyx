{ config, lib, pkgs, modulesPath, hostName, ... }:
{ 
  environment.variables = {
    #NIXOS_OZONE_WL = "1";
    __GLX_VENDOR_LIBRARY_NAME= "amd";
    LIBVA_DRIVER_NAME= "radeonsi"; # hardware acceleration
    __GL_VRR_ALLOWED="1";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    CLUTTER_BACKEND = "wayland";
    WLR_RENDERER = "vulkan";    
  };
}