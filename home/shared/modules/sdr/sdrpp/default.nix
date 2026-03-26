{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.sdr.sdrpp;
in
{
  options.nyx.modules.sdr.sdrpp = {
    enable = mkEnableOption "SDR++ wideband radio receiver software";
    package = mkOption {
      description = "Package for SDR++. Set to null on Arch (installed via pacman).";
      type = with types; nullOr package;
      default = pkgs.sdrpp;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optional (cfg.package != null) cfg.package;
  };
}
