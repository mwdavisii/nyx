{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.nextcloud;
in
{
  options.nyx.modules.app.nextcloud = {
    enable = mkEnableOption "Nextcloud desktop sync client";
    package = mkOption {
      description = "Nextcloud client package. Set to null to use system-installed nextcloud-client (e.g. via pacman on Arch).";
      type = with types; nullOr package;
      default = pkgs.nextcloud-client;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [ cfg.package ];
  };
}
