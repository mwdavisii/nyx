{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.ranger;
in
{
  options.nyx.modules.app.ranger = {
    enable = mkEnableOption "Ranger Config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ranger
    ];
    xdg.configFile."ranger".source = ../../../../config/.config/ranger;
  };
}