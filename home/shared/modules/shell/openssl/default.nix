{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfgHome = config.xdg.configHome;
  cfg = config.nyx.modules.shell.openssl;
in
{
  options.nyx.modules.shell.openssl = {
    enable = mkEnableOption "AWS CLI configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;[ openssl ];
    
  };
}