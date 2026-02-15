{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.app.chromium;
in
{
  options.nyx.modules.app.chromium = { 
    enable = mkEnableOption "Chromium app"; 
  };

  config = mkIf cfg.enable {
  home.packages = with pkgs;    
      [
        chromium
      ];
  };
}
