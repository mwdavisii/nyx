{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.app.wezterm;
in
{
  options.nyx.modules.app.wezterm = {
    enable = mkEnableOption "wezterm configuration";
    package = mkOption {
      description = "Package for wezterm";
      type = with types; nullOr package;
      default = pkgs.wezterm;
    };
    fontSize = mkOption {
      description = "Override font size";
      type = with types; nullOr int;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        wezterm
      ];
    xdg.configFile."wezterm".source = ../../../../config/.config/wezterm;
    xdg.dataFile."wezterm/nyx.lua".text =
      let
        fontText =
          if cfg.fontSize != null then ''
            font_size = ${toString cfg.fontSize},
          '' else "";
      in
      ''
        return {
          ${fontText}
        }
      '';
  };
}
