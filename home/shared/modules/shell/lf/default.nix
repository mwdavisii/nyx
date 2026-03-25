# home/shared/modules/shell/lf/default.nix
{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.lf;
in
{
  options.nyx.modules.shell.lf = {
    enable = mkEnableOption "lf file manager with ueberzugpp image preview";
    ueberzugppPackage = mkOption {
      type = types.nullOr types.package;
      default = pkgs.ueberzugpp;
      description = "ueberzugpp package. Set to null to manage via system package manager (Arch).";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [ lf ]
      ++ optional (cfg.ueberzugppPackage != null) cfg.ueberzugppPackage;

    xdg.configFile."lf" = {
      source = ../../../../config/.config/lf;
      executable = true;
      recursive = true;
    };
  };
}
