{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.app.pearDesktop;
in
{
  options.nyx.modules.app.pearDesktop = { enable = mkEnableOption "Pear Desktop (YouTube Music) app"; };

  config = mkIf cfg.enable {
    home.packages = [ pkgs."pear-desktop" ];
  };
}
