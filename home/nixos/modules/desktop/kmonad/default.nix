{ config, lib, pkgs, agenix, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.kmonad;
in
{
  options.nyx.modules.desktop.kmonad = {
    enable = mkEnableOption "kmonad";
  };

  config = mkIf cfg.enable {
    xdg.configFile."kmonad".source = ../../../../config/.config/kmonad;
  };
}
