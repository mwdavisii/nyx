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

    # ens18: trunk only (no L3)
    systemd.network.networks."10-ens18" = {
      matchConfig.Name = "ens18";
      networkConfig.LinkLocalAddressing = "no";
    };

    # ens19: Infrastructure (10.40.250.21/24 via 10.40.250.1)
    systemd.network.networks."20-ens19" = {
      matchConfig.Name = "ens19";
      address = [ "10.40.250.21/24" ];

      # Policy rule: traffic FROM 10.40.250.21 → table 250 (priority 1000)
      routingPolicyRules = [
        { From = "10.40.250.21/32"; Table = 250; Priority = 1000; Family = "ipv4"; }
      ];

      # Routes in table 250
      routes = [
        { Destination = "0.0.0.0/0"; Gateway = "10.40.250.1"; Table = 250; }
        { Destination = "10.40.250.0/24"; Table = 250; }
        
        { Destination = "0.0.0.0/0"; Gateway = "10.40.250.1"; }
      ];
    };

    # ens20: Home Automation (10.40.50.21/24 via 10.40.50.1)
    systemd.network.networks."30-ens20" = {
      matchConfig.Name = "ens20";
      address = [ "10.40.50.21/24" ];

      # Policy rule: traffic FROM 10.40.50.21 → table 150 (priority 1001)
      routingPolicyRules = [
        { From = "10.40.50.21/32"; Table = 150; Priority = 1001; Family = "ipv4"; }
      ];

      # Routes in table 150
      routes = [
        { Destination = "0.0.0.0/0"; Gateway = "10.40.50.1"; Table = 150; }
        { Destination = "10.40.50.0/24"; Table = 150; }
      ];
    };

    # rp_filter loose for multi-homing
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = "2";
      "net.ipv4.conf.default.rp_filter" = "2";
    };
    networkConfig.DefaultRouteOnDevice = true;
    networking.nameservers = [ "192.168.0.2" "10.40.250.2"];
  };
}