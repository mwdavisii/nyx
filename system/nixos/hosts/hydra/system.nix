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
      address = "10.40.250.221";
      prefixLength = 24;
    }
    ];
    #IoT vlan
    networking.interfaces.ens19.ipv4.addresses = [
      {
        address = "10.40.40.30";
        prefixLength = 24;
      }
    ];
    # Security VLAN
    networking.interfaces.ens20.ipv4.addresses = [
      {
        address = "10.40.70.30";
        prefixLength = 24;
      }
    ];
    networking.interfaces.ens22.ipv4.addresses = [
      {
        address = "10.40.250.30";
        prefixLength = 24;
      }
    ];
    networking.interfaces.ens21.ipv4.addresses = [
      {
        address = "10.40.200.30";
        prefixLength = 24;
      }
    ];
    networking.defaultGateway = "10.40.250.1";
    networking.nameservers = ["10.40.250.54" "10.40.250.53"];
    time.hardwareClockInLocalTime = true;

    networking.firewall = {
      enable = false;
      allowedTCPPorts = [ 
        6443
        53
        443
        80
        8080
        3012];
      allowedUDPPorts = [ 
        53
      ];
      trustedInterfaces = [ "cni0" "flannel.1" "ens18" "ens19" "ens20" "ens21" "ens22"];
    };
    # Configure keymap in X11
    services = {
      openssh.enable = true;
      qemuGuest.enable = true;
 
    };
  };
}