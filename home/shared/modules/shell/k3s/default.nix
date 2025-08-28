{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.k3sTooling;
in
{
  options.nyx.modules.shell.k3sTooling = {
        enable = mkEnableOption "K3s Installation";
    };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        k3s
        jq
        k9s
        fluxcd
        kustomize
        flux
        open-policy-agent
      ];
    };
  };
}