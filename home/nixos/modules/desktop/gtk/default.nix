{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.nyx.modules.desktop.gtk;
in
{
  options.nyx.modules.desktop.gtk = { enable = mkEnableOption "GTK Configuration"; };
  config = mkIf cfg.enable {
    gtk = {
      enable = true;
      iconTheme = {
        #name = "Yaru-magenta-dark";
        #package = pkgs.yaru-theme;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };

      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
        #name = "Tokyonight-Dark-B-LB";
        #package = pkgs.tokyo-night-gtk;
      };
    };
  };
}
