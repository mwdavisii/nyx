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
    # Manage shaders and helper script, but NOT config — pywal owns that file
    xdg.configFile."cava/shaders" = {
      source = ../../../../config/.config/cava/shaders;
      recursive = true;
    };
    xdg.configFile."cava/start.sh" = {
      source = ../../../../config/.config/cava/start.sh;
    };
  };
}
