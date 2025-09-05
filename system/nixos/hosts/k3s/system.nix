{ config, lib, pkgs, modulesPath, hostName, ... }:
{

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix

    ];
  config = {
    services = {
      openssh.enable = true;
      qemuGuest.enable = true;
 
    };
    networking.useNetworkd = true;
    networking.useDHCP = false;

    # VLAN for Infrastructure (mgmt) on trunk
    systemd.network.netdevs."ens18.250" = {
      netdevConfig = {
        Name = "ens18.250";
        Kind = "vlan";
      };
      vlanConfig.Id = 250;
    };

    systemd.network.networks."10-ens18.250" = {
      matchConfig.Name = "ens18.250";
      address = [ "10.40.250.21/24" ];
      gateway = [ "10.40.250.1" ];  # Default route
      dns = [ "192.168.0.2" "10.40.250.2" ];
      domains = [ "~." ];
    };

    # Just bring trunk up with no L3
    systemd.network.networks."10-ens18" = {
      matchConfig.Name = "ens18";
      networkConfig.LinkLocalAddressing = "no";
    };
  };
}