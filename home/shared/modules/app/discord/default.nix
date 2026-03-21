{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.app.discord;
in
{
  options.nyx.modules.app.discord = {
    enable = mkEnableOption "discord app";
    package = mkOption {
      description = "Package for discord. Set to null to use system-installed discord (e.g. via pacman on Arch).";
      type = with types; nullOr package;
      default = pkgs.discord;
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkIf (cfg.package != null)
      [
        # This is required to be from unstable as discord will sometimes soft-lock
        # on "there is an update" screen.
        cfg.package
      ];
  };
}
