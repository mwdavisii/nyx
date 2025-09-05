{ config, lib, pkgs, modulesPath, hostName, ... }:
{

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix

    ];
  config = {
   { config, pkgs, ... }:

{
    #### Interfaces ####
    # Trunk: carry VLANs, no L3 config on the host for now
    networking.interfaces.ens18.useDHCP = false;


    # Infra (VLAN 250)
    networking.interfaces.ens19 = {
      useDHCP = false;
      ipv4.addresses = [{ address = "10.40.250.21"; prefixLength = 24; }];
    };

    # Home Automation (VLAN 50)
    networking.interfaces.ens20 = {
      useDHCP = false;
      ipv4.addresses = [{ address = "10.40.50.21"; prefixLength = 24; }];
    };

    #### Routing tables ####
    networking.routingTables = {
      infra250 = 250;
      ha50     = 150;
    };

    #### Routes in per-interface tables (no defaults in main) ####
    networking.interfaces.ens19.ipv4.routes = [
      { address = "10.40.250.0"; prefixLength = 24; table = "infra250"; }
      { address = "0.0.0.0";     prefixLength = 0;  via = "10.40.250.1"; table = "infra250"; }
    ];
    networking.interfaces.ens20.ipv4.routes = [
      { address = "10.40.50.0"; prefixLength = 24; table = "ha50"; }
      { address = "0.0.0.0";    prefixLength = 0;  via = "10.40.50.1"; table = "ha50"; }
    ];

    #### Policy rules: pick table by source IP ####
    networking.routingRules = [
      { family = "ipv4"; from = "10.40.250.21/32"; table = "infra250"; priority = 1000; }
      { family = "ipv4"; from = "10.40.50.21/32";  table = "ha50";     priority = 1001; }
    ];

    #### rp_filter: loose mode for multi-homed hosts ####
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = "2";
      "net.ipv4.conf.default.rp_filter" = "2";
    };

    #### DNS (system-wide) ####
    # Keep DNS on your preferred segment (often infra):
    networking.nameservers = [ "192.168.0.2" "10.40.250.2"];
  
    services = {
      openssh.enable = true;
      qemuGuest.enable = true;
 
    };
  };
}