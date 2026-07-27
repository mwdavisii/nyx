{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.app.remmina;
in
{
  options.nyx.modules.app.remmina = {
    enable = mkEnableOption "remmina remote desktop client";
    package = mkOption {
      description = "Package for remmina. Set to null to use system-installed remmina (e.g. via pacman on Arch).";
      type = with types; nullOr package;
      default = pkgs.remmina;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [ cfg.package ];
  };
}
