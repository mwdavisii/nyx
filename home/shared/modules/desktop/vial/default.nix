{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.vial;
in
{
  options.nyx.modules.desktop.vial = {
    enable = mkEnableOption "vial configuration";
    package = mkOption {
      description = "Package for vial";
      type = with types; nullOr package;
      default = pkgs.vial;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [
      cfg.package
    ];
  };
}
