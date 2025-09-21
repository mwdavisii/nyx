{ config, lib, pkgs, modulesPath, hostName, ... }:
{

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix

    ];
  config = {
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = "2";
      "net.ipv4.conf.default.rp_filter" = "2";
      "net.ipv4.ip_forward" = "1";
    };
    networking.networkmanager.enable = lib.mkForce false;
    networking.useDHCP = lib.mkDefault false;

    #host
    networking.interfaces.ens18.ipv4.addresses = [
    {
      address = "10.40.250.102";
      prefixLength = 24;
    }
    ];
    # core vlan
    networking.interfaces.ens19.ipv4.addresses = [
      {
        address = "10.40.20.102";
        prefixLength = 24;
      }
    ];
    # Wifi Vlan
    networking.interfaces.ens20.ipv4.addresses = [
      {
        address = "10.40.30.102";
        prefixLength = 24;
      }
    ];
    #Iot
    networking.interfaces.ens21.ipv4.addresses = [
      {
        address = "10.40.40.102";
        prefixLength = 24;
      }
    ];
    #Home Automation
    networking.interfaces.ens22.ipv4.addresses = [
      {
        address = "10.40.50.102";
        prefixLength = 24;
      }
    ];
    #Security
    networking.interfaces.ens23.ipv4.addresses = [
      {
        address = "10.40.70.102";
        prefixLength = 24;
      }
    ];
    #dmz
    networking.interfaces.ens24.ipv4.addresses = [
      {
        address = "10.40.200.102";
        prefixLength = 24;
      }
    ];
    networking.defaultGateway = "10.40.250.1";
    networking.nameservers = ["10.40.250.54" "10.40.250.53"];
    time.hardwareClockInLocalTime = true;

    networking.firewall = {
      enable = false;
      allowedTCPPorts = [ 
        6443];
    };
    # Configure keymap in X11
    services = {
      openssh.enable = true;
      qemuGuest.enable = true;
 
    };
  };
}