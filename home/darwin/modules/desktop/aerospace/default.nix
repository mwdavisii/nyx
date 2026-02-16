{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfg = config.nyx.modules.desktop.aerospace;
in
{
  options.nyx.modules.desktop.aerospace = {
    enable = mkEnableOption "aerospace";
  };

  config = mkIf cfg.enable {
    home.file.".aerospace.toml".source = ../../../../config/.config/aerospace/aerospace.toml;
  };
}