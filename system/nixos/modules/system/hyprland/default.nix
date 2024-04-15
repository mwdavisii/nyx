{ config, lib, pkgs, modulesPath, hostName, userConf, ... }:
with lib;
let
  cfg = config.nyx.modules.system.hyprland;
in
{
  options.nyx.modules.system.hyprland = { 
    enable = mkEnableOption "Include Hyprland Login Service"; 
  };
  config = mkIf cfg.enable {
    programs.hyprland.enable = true;
  };
}
