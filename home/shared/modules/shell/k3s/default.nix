{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.dev.k3sTooling;
in
{
  options.nyx.modules.dev.k3sTooling = {
        enable = mkEnableOption "K3s Installation";
    };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        k3s
        jq
        k9s
        fluxcd
        kubectl
        kustomize
        flux
        open-policy-agent
      ];
    };
  };
}