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

    # Infra VLAN 250 (net1 → ens19)
    systemd.network.networks."20-ens19" = {
      matchConfig.Name = "ens19";
      address = [ "10.40.250.21/24" ];
      gateway = [ "10.40.250.1" ];
      dns = [ "10.40.250.2" "1.1.1.1" ];
      domains = [ "~." ];
    };

    # HA VLAN 50 (net2 → ens20)
    systemd.network.networks."30-ens20" = {
      matchConfig.Name = "ens20";
      address = [ "10.40.50.21/24" ];
    };

    # If you want net0/ens18 up but unused
    systemd.network.networks."10-ens18" = {
      matchConfig.Name = "ens18";
      networkConfig.LinkLocalAddressing = "no";
    };
  };
}