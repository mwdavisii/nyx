
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

    # …or tell us which NIC to read from
    interface = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Interface to auto-detect the primary IPv4 from.";
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
    
    taintControlPlane = mkOption {
      type = types.bool;
      default = false;
      description = "Taint the control-plane node to prevent scheduling of workloads.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.k3s = {
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
          ++ (optional cfg.taintControlPlane "--node-taint=node-role.kubernetes.io/control-plane=true:NoSchedule")
          ++ (if cfg.networkingBackend == "cilium" then [
              "--flannel-backend=none"
              "--disable-kube-proxy"
              "--disable-network-policy"
              "--disable=servicelb"
              "--disable=traefik"
            ] else if cfg.networkingBackend == "metallb" then [
              "--disable servicelb"
            ] else []
          );
      };
      # Open the API port
      networking.firewall.allowedTCPPorts = [ 6443];
    }
  ]);
}
