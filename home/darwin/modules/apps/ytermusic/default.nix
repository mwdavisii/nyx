{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.ytermusic;
in
{
  options.nyx.modules.app.ytermusic = {
    enable = mkEnableOption "ytermusic (TUI YouTube Music player)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ytermusic
    ];
  };
}
