{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.scrcpy;
in
{
  options.nyx.modules.app.scrcpy = {
    enable = mkEnableOption "Screen Copy for Android";
  };

  config = mkIf cfg.enable {
    # go ahead and install adb here since it's required
    home.packages = with pkgs; [
        scrcpy
    ];
  };
}
