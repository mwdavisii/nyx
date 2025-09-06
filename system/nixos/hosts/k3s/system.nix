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

    systemd.network.networks."20-ens18" = {
      matchConfig.Name = "ens18";          # Infra (tag 250 in Proxmox)
      address = [ "10.40.250.21/24" ];
      gateway = [ "10.40.250.1" ];
      dns = [ "192.168.0.2" "10.250.0.2" ];
    };

    systemd.network.networks."30-ens19" = {
      matchConfig.Name = "ens19";          # HA (tag 50 in Proxmox)
      address = [ "10.40.50.21/24" ];
    };
}