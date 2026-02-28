{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.scrcpy;
in
{
  options.nyx.modules.app.scrcpy = {
    enable = mkEnableOption "Screen Copy for Android";
    package = mkOption {
      description = "Package for scrcpy";
      type = with types; nullOr package;
      default = pkgs.scrcpy;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [
      cfg.package
    ];
  };
}
