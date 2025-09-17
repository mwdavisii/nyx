
{ config, lib, pkgs, modulesPath, hostName, userConf, ... }:
with lib;

let
  inherit (lib) mkIf mkMerge mkOption mkEnableOption types optional optionals concatMap;
  cfg = config.nyx.modules.system.k3s;

  # Helper: first IPv4 address on a given interface, or null if missing
  firstIPv4On = ifName:
    let
      iface = config.networking.interfaces.${ifName} or null;
      addrs = if iface == null then [] else (iface.ipv4.addresses or []);
    in if addrs == [] then null else addrs.[0].address;

  # Resolve node/advertise IP
  resolvedNodeIp =
    if cfg.address != null then cfg.address
    else if cfg.interface != null then firstIPv4On cfg.interface
    else null;

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
      example = "10.40.250.201";
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
      example = [ "k3s.mydomain.com" "10.40.250.201" ];
      description = "Values to pass as --tls-san (list).";
    };
    networkingBackend = lib.mkOption {
      type = lib.types.enum [ "metallb" "cilium" "traefik" ];
      description = ''
      Which networking / load balancer stack to use for K3s.
      Must be either "metallb" or "cilium".
      '';
      };
  };

  config = mkIf cfg.enable (mkMerge [
    (lib.asserts.assertMsg (resolvedNodeIp != null)
      ''nyx.modules.system.k3s: Either set `address` or set `interface` to auto-detect an IP.'')
    {
      services.k3s = {
        enable = true;
        role = "server";
        nodeIp = resolvedNodeIp;
        clusterCIDR = cfg.clusterCIDR;
        serviceCIDR = cfg.serviceCIDR;

        extraFlags =
          [
            "--bind-address=0.0.0.0"
            "--advertise-address=${resolvedNodeIp}"
            "--write-kubeconfig-mode=0644"
          ]
          ++ tlsSansFlags
          ++ (if cfg.networkingBackend == "cilium" then [
              "--flannel-backend=none"
              "--disable-kube-proxy"
              "--disable-network-policy"
              "--disable=servicelb"
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
