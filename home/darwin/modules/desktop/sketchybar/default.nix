{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.sketchybar;
in
{
  options.nyx.modules.desktop.sketchybar = {
    enable = mkEnableOption "sketchybar";
  };

  config = mkIf cfg.enable {
    home.file.".config/sketchybar/sketchybarrc".source = ../../../../config/.config/sketchybar/sketchybarrc;
    home.file.".config/sketchybar/plugins".source = ../../../../config/.config/sketchybar/plugins;
  };
}
