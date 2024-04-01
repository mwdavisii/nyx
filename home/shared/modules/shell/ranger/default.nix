{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.shell.ranger;
in
{
  options.nyx.modules.shell.ranger = {
    enable = mkEnableOption "Ranger Config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ranger
    ];
    xdg.configFile."ranger".source = ../../../../config/.config/ranger;
  };
}
