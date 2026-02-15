{ config, lib, pkgs, modulesPath, hostName, userConf, inputs, ... }:
with lib;
let
  cfg = config.nyx.modules.system.hyprland;
in
{
  options.nyx.modules.system.hyprland = { 
    enable = mkEnableOption "Include Hyprland Login Service"; 
  };
  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
  };
}
