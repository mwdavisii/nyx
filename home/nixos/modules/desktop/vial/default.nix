{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.vial;
in
{
  options.nyx.modules.desktop.vial = {
    enable = mkEnableOption "vial configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        vial
      ];
  };

}