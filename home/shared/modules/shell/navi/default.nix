{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.navi;
in
{
  options.nyx.modules.shell.navi = {
    enable = mkEnableOption "navi interactive cheatsheet tool";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.navi ];
  };
}
