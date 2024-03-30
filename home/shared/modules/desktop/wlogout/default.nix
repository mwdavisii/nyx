{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.wlogout;
in
{
  options.nyx.modules.desktop.wlogout = {
    enable = mkEnableOption "WLogout Config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wlogout
    ];
    xdg.configFile."wlogout".source = ../../../../config/.config/wlogout;
  };
}