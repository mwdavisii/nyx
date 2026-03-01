{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.kanshi;
in
{
  options.nyx.modules.desktop.kanshi = {
    enable = mkEnableOption "kanshi";
    package = mkOption {
      description = "Package for kanshi";
      type = with types; nullOr package;
      default = pkgs.kanshi;
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [
      cfg.package
    ];
    xdg.configFile."kanshi".source = ../../../../config/.config/kanshi;
    services.kanshi = {
      enable = true;
      systemdTarget = "hyprland-session.target";
    };
  };
}
