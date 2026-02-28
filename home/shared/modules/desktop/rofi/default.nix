{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.rofi;
in
{
  options.nyx.modules.desktop.rofi = {
    enable = mkEnableOption "rofi configuration";
    package = mkOption {
      description = "Package for rofi";
      type = with types; nullOr package;
      default = pkgs.rofi;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [
      cfg.package
    ];
    xdg.configFile."rofi".source = ../../../../config/.config/rofi;
  };
}
