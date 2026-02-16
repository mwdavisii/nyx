{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfg = config.nyx.modules.desktop.amethyst;
in
{
  options.nyx.modules.desktop.amethyst = {
    enable = mkEnableOption "amethyst";
  };

  config = mkIf cfg.enable {
    xdg.configFile."amethyst".source = ../../../../config/.config/amethyst;
  };
}