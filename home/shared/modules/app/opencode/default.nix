{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.app.opencode;
in
{
  options.nyx.modules.app.opencode = {
    enable = mkEnableOption "opencode app";
    package = mkOption {
      description = "Package for opencode. Set to null to use system-installed opencode (e.g. via pacman on Arch).";
      type = with types; nullOr package;
      default = pkgs.opencode;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [ cfg.package ];
  };
}
