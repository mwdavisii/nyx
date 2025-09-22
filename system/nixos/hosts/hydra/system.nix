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
      address = "10.40.250.100";
      prefixLength = 24;
    }
    ];
    networking.defaultGateway = "10.40.250.1";
    networking.nameservers = ["10.40.250.54" "10.40.250.53"];
    time.hardwareClockInLocalTime = true;

    # Configure keymap in X11
    services = {
      openssh.enable = true;
      qemuGuest.enable = true;
 
    };
  };
}