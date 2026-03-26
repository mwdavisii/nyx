{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.sdr.gqrx;
in
{
  options.nyx.modules.sdr.gqrx = {
    enable = mkEnableOption "GQRX SDR receiver";
    package = mkOption {
      description = "Package for GQRX. Set to null on Arch (installed via pacman).";
      type = with types; nullOr package;
      default = pkgs.gqrx;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optional (cfg.package != null) cfg.package;
  };
}
