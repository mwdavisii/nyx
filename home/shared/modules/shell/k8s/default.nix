{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.k8sTooling;
in
{
  options.nyx.modules.shell.k8sTooling = {
    enable = mkEnableOption "Kubernetes Tooling";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;[
    yq
    kustomize
    cilium-cli
    kubernetes-helm
    sops
    jq 
    k9s
    fluxcd
    kubectl
    kustomize
    flux
    open-policy-agent
    sops
    ];
  };
}
