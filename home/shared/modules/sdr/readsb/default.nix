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
    # CLI-only install — no systemd service wiring. Run manually or add a
    # system-level service module if continuous ADS-B decoding is needed later.
    home.packages = with pkgs; [ readsb ];
  };
}
