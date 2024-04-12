{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfgHome = config.xdg.configHome;
  cfg = config.nyx.modules.app.finicky;
in
{
  options.nyx.modules.app.finicky = {
    enable = mkEnableOption "MacOS Default Browser Tool";
  };

  config = mkIf cfg.enable {
    ## note that finicky is installed from brew, this just maps the config.
    home.file.".finicky.js".source = ../../../../config/.config/finicky/finicky.js;
  };
}

