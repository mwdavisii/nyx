{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.kanshi;
  sharedDir = ../../../../config/.config/kanshi;
in
{
  options.nyx.modules.desktop.kanshi = {
    enable = mkEnableOption "kanshi";
    package = mkOption {
      description = "Package for kanshi";
      type = with types; nullOr package;
      default = pkgs.kanshi;
    };

    config = mkOption {
      type = with types; nullOr (either path str);
      default = null;
      description = ''
        Content (string) or path to a kanshi config file. When null, the entire
        shared kanshi directory is sourced (includes config, ws-to-monitor.sh,
        and switch.sh). When set, only the config is overridden and the scripts
        are sourced individually from the shared directory.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals (cfg.package != null) [
      cfg.package
    ];

    xdg.configFile =
      let c = cfg.config;
      in
      if c == null then
        { "kanshi".source = sharedDir; }
      else
        {
          "kanshi/config" =
            if builtins.isString c then { text = c; } else { source = c; };
          "kanshi/ws-to-monitor.sh".source = "${sharedDir}/ws-to-monitor.sh";
          "kanshi/switch.sh".source = "${sharedDir}/switch.sh";
        };

    services.kanshi = {
      enable = true;
      systemdTarget = "hyprland-session.target";
    };
  };
}
