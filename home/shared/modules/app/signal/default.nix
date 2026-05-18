{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.signal;
in
{
  options.nyx.modules.app.signal = {
    enable = mkEnableOption "Signal";
    package = mkOption {
      description = "Package for Signal. Set to null to use system-installed signal (e.g. via pacman on Arch).";
      type = with types; nullOr package;
      default = pkgs.signal-desktop;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [ cfg.package ];
  };
}
