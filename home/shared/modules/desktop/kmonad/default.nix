{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.kmonad;
in
{
  options.nyx.modules.desktop.kmonad = {
    enable = mkEnableOption "kmonad";
    package = mkOption {
      description = "Package for kmonad";
      type = with types; nullOr package;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [
      cfg.package
    ];
    xdg.configFile."kmonad".source = ../../../../config/.config/kmonad;
  };
}
