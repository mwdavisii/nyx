{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.signal;
in
{
  options.nyx.modules.app.signal = {
    enable = mkEnableOption "Signal";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
        signal-desktop
    ];
  };
}
