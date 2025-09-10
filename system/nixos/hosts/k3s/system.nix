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
    networking.interfaces.ens21.ipv4.addresses = [
      {
        address = "10.40.200.40";
        prefixLength = 24;
      }
    ];
    networking.defaultGateway = "10.40.250.1";
    networking.nameservers = ["10.40.250.53" "10.40.250.54"];
    time.hardwareClockInLocalTime = true;

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 
        6443
        53
        443
        80
        8080];
      trustedInterfaces = [ "cni0" "flannel.1" "ens18"];

    # Configure keymap in X11
    services = {
      openssh.enable = true;
      qemuGuest.enable = true;
 
    };
  };
}


