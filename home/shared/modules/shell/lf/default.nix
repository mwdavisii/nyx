{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.shell.lf;
in
{
  options.nyx.modules.shell.lf = {
    enable = mkEnableOption "lf configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        lf
      ];
    xdg.configFile."lf" = {
      source = ../../../../config/.config/lf;
      executable = true;
      recursive = true;
    };
  };
}
