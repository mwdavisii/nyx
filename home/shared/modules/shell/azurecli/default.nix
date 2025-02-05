{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  #inherit (lib) mkIf isDerivation;
  #inherit (builtins) filter attrValues;
  #azure-cli = pkgs.azure-cli.withExtensions (filter (item: isDerivation item) (attrValues pkgs.azure-cli-extensions) (attrValues != pkgs.azure-cli-extensions.blockchain));
  cfgHome = config.xdg.configHome;
  cfg = config.nyx.modules.shell.azurecli;
  
in
{
  options.nyx.modules.shell.azurecli = {
    enable = mkEnableOption "Azure CLI configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (azure-cli.withExtensions [ 
        azure-cli.extensions.aks-preview 
        azure-cli-extensions.k8s-extension
        azure-cli.extensions.dns-resolver
        #azure-cli-extensions.k8s-configuration
        #azure-cli.extensions.k8s-configuration 
      ])
    ];
  };
}