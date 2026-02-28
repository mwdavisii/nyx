{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.wlogout;
in
{
  options.nyx.modules.desktop.wlogout = {
    enable = mkEnableOption "WLogout Config";
  };

  # wlogout replaced by rofiPowerMenu — module kept for option backwards compat
  config = mkIf cfg.enable { };
}
