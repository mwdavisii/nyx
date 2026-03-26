{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.sdr.readsb;
in
{
  options.nyx.modules.sdr.readsb = {
    enable = mkEnableOption "readsb ADS-B decoder (aircraft tracking)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ readsb ];
  };
}
