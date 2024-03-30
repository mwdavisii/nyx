{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.neofetch;
in
{
  options.nyx.modules.shell.neofetch = {
    enable = mkEnableOption "neofetch configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.glow ];
    xdg.configFile."neofetch".source = ../../../config/.config/neofetch;
  };
}
