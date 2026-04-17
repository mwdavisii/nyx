{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.ytfzf;
in
{
  options.nyx.modules.app.ytfzf = {
    enable = mkEnableOption "ytfzf (terminal YouTube player)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ytfzf
      yt-dlp
      mpv
    ];
  };
}
