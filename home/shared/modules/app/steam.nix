{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.steam;
in
{
  options.nyx.modules.app.steam = {
    enable = mkEnableOption "Steam Games";
  };

  config = mkIf cfg.enable {
    # go ahead and install adb here since it's required
    home.packages = with pkgs; [
        steam
    ];
  };
}



