{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfgHome = config.xdg.configHome;
  cfg = config.nyx.modules.shell.openssl;
in
{
  options.nyx.modules.shell.openssl = {
    enable = mkEnableOption "OpenSSL in user shell environment";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;[ openssl ];
    
  };
}