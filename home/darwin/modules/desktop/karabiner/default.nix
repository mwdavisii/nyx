{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfg = config.nyx.modules.desktop.karabiner;
in
{
  options.nyx.modules.desktop.karabiner = {
    enable = mkEnableOption "karabiner";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      karabiner-elements
    ];
    xdg.configFile."karabiner".source = ../../../../config/.config/karabiner;
  };
}