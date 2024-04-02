{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.gaming.retroarch;
in
{
  options.nyx.modules.gaming.retroarch = {
    enable = mkEnableOption "Steam Games";
  };

  config = mkIf cfg.enable {
    # go ahead and install adb here since it's required
    home.packages = with pkgs; [
      retroarchFull
      retroarch-joypad-autoconfig
      retroarch-assets
    ];
  };
}



