{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.obsidian;
in
{
  options.nyx.modules.app.obsidian = {
    enable = mkEnableOption "obsidian";
    package = mkOption {
      description = "Package for obsidian";
      type = with types; nullOr package;
      default = pkgs.obsidian;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [
      cfg.package
    ];
  };
}



