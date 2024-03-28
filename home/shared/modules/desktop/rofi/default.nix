{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.rofi;
in
{
  options.nyx.modules.desktop.rofi = {
    enable = mkEnableOption "rofi configuration";
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
    };
    xdg.configFile."rofi".source = ../../../../config/.config/rofi;
  };
}
