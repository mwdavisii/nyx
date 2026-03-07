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
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };

      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };
}
