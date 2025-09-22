
{ config, lib, pkgs, modulesPath, hostName, userConf, ... }:
with lib;

let
  inherit (lib) mkIf mkMerge mkOption mkEnableOption types optional optionals concatMap;
  cfg = config.nyx.modules.system.k3s;
  # Make --tls-san flags
  tlsSansFlags = map (s: "--tls-san=${s}") cfg.tlsSans;
in
{
  options.nyx.modules.system.k3s = {
    enable = mkEnableOption "K3s Install Settings";

    # Either set a fixed address…
    address = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "10.40.40.40";
      description = ''
        IPv4 address for k3s (--node-ip and --advertise-address). If null,
        we'll use the first IPv4 found on `interface`.
      '';
    };

    clusterCIDR = mkOption {
      type = types.str;
      default = "10.42.0.0/16";
    };

    serviceCIDR = mkOption {
      type = types.str;
      default = "10.43.0.0/16";
    };

    tlsSans = mkOption {
      type = types.listOf types.str;
      # Hostname + localhost by default; you can add FQDNs/IPs in your host config
      default = [ config.networking.hostName "127.0.0.1" ];
      example = [ "k3s.mydomain.com" "10.40.40.40" ];
      description = "Values to pass as --tls-san (list).";
    };
    
    networkingBackend = lib.mkOption {
      type = lib.types.enum [ "metallb" "cilium" "traefik" ];
      description = ''
      Which networking / load balancer stack to use for K3s.
      Must be either "metallb" or "cilium".
      '';
    };

    serverAddress = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The IP address of the k3s server. Required for agents.";
    };

    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to the file containing the cluster join token. Required for agents.";
    };

    taintControlPlane = mkOption {
      type = types.bool;
      default = false;
      description = "Taint the control-plane node to prevent scheduling of workloads.";
    };
  };
  config = lib.mkIf cfg.enable {
    services.k3s = lib.mkMerge [
      # --- Common configuration for both roles ---
      {
        enable = true;
        role = "server";
        clusterInit = true;
        extraFlags =
          [
            "--bind-address=0.0.0.0"
            "--advertise-address=${cfg.address}"
            "--write-kubeconfig-mode=0644"
            "--node-ip=${cfg.address}"
          ]
          ++ tlsSansFlags
          ++ lib.optionals (cfg.taintControlPlane) [ "--node-taint=node-role.kubernetes.io/control-plane=true:NoSchedule" ]
          ++ lib.optionals (cfg.networkingBackend == "cilium") [
              "--flannel-backend=none"
              "--disable-kube-proxy"
              "--disable-network-policy"
              "--disable=servicelb"
              "--disable=traefik"
              "--cluster-cidr=${cfg.clusterCIDR}"
              "--service-cidr=${cfg.serviceCIDR}"
            ]
          ++ lib.optionals (cfg.networkingBackend == "metallb") [
              "--disable=servicelb"
            ];
        }
    ];

    # Open the API port only on the server
    networking.firewall = {
      enable = true; # Ensure the firewall is explicitly managed
      trustedInterfaces = [ "cni0" "ens18"];
      allowedTCPPorts = [ 
        6443 # Kubernetes API Server
        4240 # Cilium Health Checks
      ];
      allowedUDPPorts = [ 
        8472 # Cilium VXLAN Tunnel
      ];
    };
  };
}
