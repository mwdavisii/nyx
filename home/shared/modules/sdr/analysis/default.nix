{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.sdr.analysis;
in
{
  options.nyx.modules.sdr.analysis = {
    enable = mkEnableOption "SDR signal analysis tools (multimon-ng protocol decoder)";
  };

  config = mkIf cfg.enable {
    # inspectrum (Qt5 GUI) is intentionally NOT installed here — it has the NixGL
    # issue on Arch and is installed via pacman in 02-install-packages.sh when
    # INSTALL_SDR=y. Disabling this module does not remove inspectrum.
    home.packages = with pkgs; [ multimon-ng ];
  };
}
