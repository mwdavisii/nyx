{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfg = config.nyx.modules.desktop.yabai;
in
{
  options.nyx.modules.desktop.yabai = {
    enable = mkEnableOption "yabai tiling manager";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        yabai
      ];
  };
}
