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
  #### Interfaces ####
    networking.interfaces.ens18.useDHCP = false; # trunk, no L3

    networking.interfaces.ens19 = {
      useDHCP = false;
      ipv4.addresses = [{ address = "10.40.250.21"; prefixLength = 24; }];
      ipv4.routes = [
        { address = "0.0.0.0"; prefixLength = 0; via = "10.40.250.1"; table = 250; }
        # connected route auto-exists; explicit is optional:
        { address = "10.40.250.0"; prefixLength = 24; table = 250; }
      ];
    };

    networking.interfaces.ens20 = {
      useDHCP = false;
      ipv4.addresses = [{ address = "10.40.50.21"; prefixLength = 24; }];
      ipv4.routes = [
        { address = "0.0.0.0"; prefixLength = 0; via = "10.40.50.1"; table = 150; }
        { address = "10.40.50.0"; prefixLength = 24; table = 150; }
      ];
    };

    #### iproute2 tables + rules (policy routing) ####
    networking.iproute2.tables = {
      infra250 = 250;
      ha50     = 150;
    };

    networking.iproute2.rules = [
      { family = "ipv4"; from = "10.40.250.21/32"; priority = 1000; routingTable = "infra250"; }
      { family = "ipv4"; from = "10.40.50.21/32";  priority = 1001; routingTable = "ha50";     }
    ];

    #### rp_filter loose for multi-homing ####
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = "2";
      "net.ipv4.conf.default.rp_filter" = "2";
    };
    networking.nameservers = [ "192.168.0.2" "10.40.250.2"];
  };
}