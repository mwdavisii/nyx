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

    # Load VLAN module
    boot.kernelModules = [ "8021q" ];

    # Trunk interface (no IP)
    systemd.network.networks."10-ens18" = {
      matchConfig.Name = "ens18";
      networkConfig.LinkLocalAddressing = "no";
    };

    # VLAN 250 — Infrastructure / mgmt
    systemd.network.netdevs."ens18.250" = {
      netdevConfig = { Name = "ens18.250"; Kind = "vlan"; };
      vlanConfig.Id = 250;
    };
    systemd.network.networks."20-ens18.250" = {
      matchConfig.Name = "ens18.250";
      address = [ "10.40.250.21/24" ];
      gateway = [ "10.40.250.1" ];    # Default route for VM
      dns = [ "10.40.250.2" "1.1.1.1" ];
      domains = [ "~." ];
    };

    # VLAN 50 — Home Automation
    systemd.network.netdevs."ens18.50" = {
      netdevConfig = { Name = "ens18.50"; Kind = "vlan"; };
      vlanConfig.Id = 50;
    };
    systemd.network.networks."30-ens18.50" = {
      matchConfig.Name = "ens18.50";
      address = [ "10.40.50.21/24" ];
    };

    # VLAN 40 — IoT (optional)
    systemd.network.netdevs."ens18.40" = {
      netdevConfig = { Name = "ens18.40"; Kind = "vlan"; };
      vlanConfig.Id = 40;
    };
    systemd.network.networks."40-ens18.40" = {
      matchConfig.Name = "ens18.40";
      address = [ "10.40.40.21/24" ];
    };
  };
}