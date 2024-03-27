{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.nyx.modules.app.waybar;
in
{
  options.nyx.modules.app.waybar = { enable = mkEnableOption "Dunst Notification Services"; };

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
