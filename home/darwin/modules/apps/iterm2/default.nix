{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfgHome = config.xdg.configHome;
  cfg = config.nyx.modules.app.iterm2;
in
{
  options.nyx.modules.app.iterm2 = {
    enable = mkEnableOption "MacOS Default Browser Tool";
  };

  config = mkIf cfg.enable {
    home.file."iterm2.itermexport".source = ../../../../config/.config/iterm2/iterm2.itermexport; 
  };
}

