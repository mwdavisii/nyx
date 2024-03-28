{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.nyx.modules.desktop.waybar;
in
{
  options.nyx.modules.desktop.waybar = { enable = mkEnableOption "Waybar Status Bar"; };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd = {
        enable = false;
        target = "graphical-session.target";
      };
    };
    xdg.configFile."waybar".source = ../../../config/.config/waybar;
  };

}
