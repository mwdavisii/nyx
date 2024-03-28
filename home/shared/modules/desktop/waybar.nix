{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.nyx.modules.desktop.waybar;
in
{
  options.nyx.modules.desktop.waybar = { enable = mkEnableOption "Waybar Status Bar"; };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      waybar
      swww
      mesa
      xdg-desktop-portal-gtk
      xdg-desktop-portal
      acpi
      wayland-protocols
      #mesa-libGL
      #hyprlock
    ];
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };
    };
    xdg.configFile."waybar".source = ../../../config/.config/waybar;
  };

}
