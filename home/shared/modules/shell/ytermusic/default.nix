{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.ytermusic;
in
{
  options.nyx.modules.shell.ytermusic = {
    enable = mkEnableOption "ytermusic YouTube Music TUI with MPRIS support";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.ytermusic ];
  };
}
