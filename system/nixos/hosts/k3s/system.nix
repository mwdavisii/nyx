{ config, lib, pkgs, modulesPath, hostName, ... }:
{

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix

    ];
  config = {
    networking.networkmanager.enable = lib.mkForce false;
    networking.useDHCP = lib.mkDefault false;

    #host
    networking.interfaces.ens18.ipv4.addresses = [
    {
      address = "10.40.250.201";
      prefixLength = 24;
    }
    ];
    #IoT vlan
    networking.interfaces.ens19.ipv4.addresses = [
      {
        address = "10.40.40.40";
        prefixLength = 24;
      }
    ];
    # Security VLAN
    networking.interfaces.ens20.ipv4.addresses = [
      {
        address = "10.40.70.40";
        prefixLength = 24;
      }
    ];
    networking.defaultGateway = "10.40.250.1";
    networking.nameservers = ["192.168.0.2" "10.40.250.2"];
    time.hardwareClockInLocalTime = true;
    # Configure keymap in X11
    services = {
      openssh.enable = true;
      qemuGuest.enable = true;
 
    };
  };
}


