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
        "--bind-address=10.40.250.201"
        "--advertise-address=10.40.250.201"
        "--tls-san=k3s.mwdavisii.com" 
        "--tls-san=10.40.250.201>"
        "--tls-san=127.0.0.1"            # DNS only; no IPs committed
        "--write-kubeconfig-mode=0644"
      ];
    };
    # Open the guest firewall for the API
    networking.firewall.allowedTCPPorts = [ 6443 ];
  };
}
