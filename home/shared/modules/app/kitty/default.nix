{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.app.kitty;
in
{
  options.nyx.modules.app.kitty = {
    enable = mkEnableOption "kitty configuration";
    package = mkOption {
      description = "Package for wezterm";
      type = with types; nullOr package;
      default = pkgs.kitty;
    };
    fontSize = mkOption {
      description = "Override font size";
      type = with types; nullOr int;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [
      cfg.package
    ];
    xdg.configFile."kitty".source = ../../../../config/.config/kitty;
  };
}


