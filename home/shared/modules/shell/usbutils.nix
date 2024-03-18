{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfgHome = config.xdg.configHome;
  cfg = config.nyx.modules.shell.usbutils;
in
{
  options.nyx.modules.shell.usbutils = {
    enable = mkEnableOption "USB Utils";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;[ usbutils ];
    
  };
}