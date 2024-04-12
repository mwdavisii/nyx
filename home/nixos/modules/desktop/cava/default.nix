{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.cava;
in
{
  options.nyx.modules.desktop.cava = {
    enable = mkEnableOption "cava Config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cava
    ];
    xdg.configFile."cava".source = ../../../../config/.config/cava;
  };
}