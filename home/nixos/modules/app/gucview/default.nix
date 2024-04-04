{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.guvcview;
in
{
  options.nyx.modules.app.guvcview = {
    enable = mkEnableOption "rofi configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        guvcview
      ];
  xdg.configFile."guvcview".source = ../../../../config/.config/guvcview;
  };

}

