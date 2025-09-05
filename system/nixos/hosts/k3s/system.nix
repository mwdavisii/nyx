{ config, lib, pkgs, modulesPath, hostName, ... }:
{

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix

    ];
  config = {
    networking.networkmanager.enable = lib.mkForce true;
    networking.useDHCP = lib.mkDefault true;
    time.hardwareClockInLocalTime = true;

    #vlan configu

    ## HA
    networking.interfaces.ens20.useDHCP = false;
    networking.interfaces.ens20.ipv4.addresses = [{
      address = "10.40.50.200";
      prefixLength = 24;
    }];
    ## HA
    #networking.interfaces.ens19.useDHCP = false;
    #networking.interfaces.ens19.ipv4.addresses = [{
    #  address = "10.40.250.200";
    #  prefixLength = 24;
    #}];
    networking.defaultGateway = "10.40.250.1";


    # Configure keymap in X11
    services = {
      openssh.enable = true;
      qemuGuest.enable = true;
 
    };
  };
}


{
  networking.vlans.eth0_70 = {
    interface = "eth0";
    id = 70;
  };
  networking.interfaces.eth0_70.ipv4.addresses = [{
    address = "10.40.70.21";
    prefixLength = 24;
  }];
  # Default route likely stays on your mgmt interface; omit here unless you want it.
}