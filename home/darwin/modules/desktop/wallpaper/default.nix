{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfg = config.nyx.modules.desktop.wallpaper;
in
{
  
  options.nyx.modules.desktop.wallpaper = {
    enable = mkEnableOption "Wallpapers";
  };

  config = mkIf cfg.enable {
    home.file.".config/wal/templates/colors-kitty".source = ../../../../config/.config/wal/templates/colors-kitty;
    home.file.".config/wallpapers".source = ../../../../config/.config/wallpapers;
    
  };
}