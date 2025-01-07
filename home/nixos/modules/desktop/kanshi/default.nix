{ config, lib, pkgs, agenix, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.kanshi;
in
{
  options.nyx.modules.desktop.kanshi = {
    enable = mkEnableOption "kanshi";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        kanshi
      ];
    xdg.configFile."kanshi".source = ../../../../config/.config/kanshi;
    services.kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";
    };
  };
}