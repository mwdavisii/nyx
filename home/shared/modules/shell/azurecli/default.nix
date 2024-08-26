{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfgHome = config.xdg.configHome;
  cfg = config.nyx.modules.shell.azurecli;
in
{
  options.nyx.modules.shell.azurecli = {
    enable = mkEnableOption "Azure CLI configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;[ azure-cli ];
    
  };
}