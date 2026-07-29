{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.app.slack;
in
{
  options.nyx.modules.app.slack = {
    enable = mkEnableOption "slack app";
    package = mkOption {
      description = "Package for slack. Set to null to use system-installed slack (e.g. via pacman on Arch).";
      type = with types; nullOr package;
      default = pkgs.slack;
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkIf (cfg.package != null)
      [
        cfg.package
      ];
  };
}
