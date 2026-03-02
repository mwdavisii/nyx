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
      # Extensions disabled: oras version pinning conflicts after nixpkgs update
      # Reinstall manually with: az extension add --name <ext>
      # - k8s-extension: requires kubernetes==24.2.0, oras==0.2.25
      # - ssh: requires oras==0.1.30
      # - aks-preview, dns-resolver: untested, may also be broken
      azure-cli
    ];
  };
}