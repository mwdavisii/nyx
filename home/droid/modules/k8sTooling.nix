{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs;[ 
    jq 
    k9s
    fluxcd
    kubectl
    kustomize
    flux
    open-policy-agent
  ];
}
