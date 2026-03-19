{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.app.youtubeMusic;
in
{
  options.nyx.modules.app.youtubeMusic = { enable = mkEnableOption "YouTube Music desktop app"; };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.youtube-music ];
  };
}
