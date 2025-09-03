{ config, lib, pkgs, modulesPath, hostName, userConf, ... }:
with lib;
let cfg = config.nyx.modules.system.k3s;
in
{
  options.nyx.modules.system.k3s = {
    enable = mkEnableOption "K3s Install Settings";
  };

    config = mkIf cfg.enable {
    services.k3s = {
      enable = true;
      role = "server";                  # run the server
      clusterInit = true;               # first/only server needs this once
      extraFlags = [
        "--bind-address=0.0.0.0"
        "--tls-san=k3s.mwdavisii.com"             # DNS only; no IPs committed
        "--write-kubeconfig-mode=0644"
      ];
    };
    # Open the guest firewall for the API
    networking.firewall.allowedTCPPorts = [ 6443 ];
  };
}
