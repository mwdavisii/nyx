{ config, lib, pkgs, ... }:

{
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
  ];
}
