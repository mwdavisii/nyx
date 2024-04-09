{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfgHome = config.xdg.configHome;
  cfg = config.nyx.modules.shell.awscliv2;
in
{
  options.nyx.modules.shell.awscliv2 = {
    enable = mkEnableOption "AWS CLI configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;[ awscli2 ];
    
  };
}