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
    networking.interfaces.eth0.eth18.addresses = [
    {
      address = "10.40.250.201";
      prefixLength = 24;
    }
    ];
    #IoT vlan
    networking.interfaces.eth0.eth19.addresses = [
      {
        address = "10.40.40.40";
        prefixLength = 24;
      }
    ];
    # Security VLAN
    networking.interfaces.eth0.eth20.addresses = [
      {
        address = "10.40.70.40";
        prefixLength = 24;
      }
    ];
    networking.defaultGateway = "10.40.250.1";

    networking.extraRoutes = [
      {
        dest = "10.40.70.0/24";
        via = "10.40.70.1";
      }
      {
        dest = "10.40.40.0/24";
        via = "10.40.40.1";
      }
    ];

    time.hardwareClockInLocalTime = true;
    # Configure keymap in X11
    services = {
      openssh.enable = true;
      qemuGuest.enable = true;
 
    };
  };
}


