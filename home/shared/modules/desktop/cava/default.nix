{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.cava;
in
{
  options.nyx.modules.desktop.cava = {
    enable = mkEnableOption "cava Config";
    package = mkOption {
      description = "Package for cava";
      type = with types; nullOr package;
      default = pkgs.cava;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [
      cfg.package
    ];
    xdg.configFile."cava" = {
      source = ../../../../config/.config/cava;
      recursive = true;
    };
    xdg.configFile."cava/shaders" = {
      source = ../../../../config/.config/cava/shaders;
      recursive = true;
    };
  };
}
