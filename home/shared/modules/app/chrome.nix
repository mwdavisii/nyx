{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.chrome;
in
{
  options.nyx.modules.app.chrome = {
    enable = mkEnableOption "Google Chrome";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      google-chrome
    ];
  };
}