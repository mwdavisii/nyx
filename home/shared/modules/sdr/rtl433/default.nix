{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.sdr.rtl433;
in
{
  options.nyx.modules.sdr.rtl433 = {
    enable = mkEnableOption "rtl_433 — decoder for 433 MHz sensor signals (weather, IoT, etc.)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ rtl_433 ];
  };
}
