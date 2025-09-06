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

    # ---- Trunk port (no L3 on the bare interface) ----
    systemd.network.networks."10-ens18" = {
      matchConfig.Name = "ens18";
      networkConfig.LinkLocalAddressing = "no";
    };

    # =========================
    # VLAN 250 — Infrastructure
    # =========================
    systemd.network.netdevs."ens18.250" = {
      netdevConfig = { Name = "ens18.250"; Kind = "vlan"; };
      vlanConfig.Id = 250;
    };

    systemd.network.networks."20-ens18.250" = {
      matchConfig.Name = "ens18.250";
      # <<< pick the host IP you want on Infra >>>
      address = [ "10.40.250.21/24" ];

      # Policy routing: traffic FROM 10.40.250.21 uses table 250
      routingPolicyRules = [
        { From = "10.40.250.21/32"; Table = 250; Priority = 1000; Family = "ipv4"; }
        # Optional but handy: any traffic TO 192.168.0.0/24 goes via Infra
        # { To = "192.168.0.0/24"; Table = 250; Priority = 900; Family = "ipv4"; }
      ];

      # Routes in table 250 + (safety) default in main
      routes = [
        { Destination = "0.0.0.0/0"; Gateway = "10.40.250.1"; Table = 250; PreferredSource = "10.40.250.21"; }
        { Destination = "10.40.250.0/24"; Table = 250; PreferredSource = "10.40.250.21"; }

        # Safety default in MAIN so the box stays reachable even if rules break
        { Destination = "0.0.0.0/0"; Gateway = "10.40.250.1"; PreferredSource = "10.40.250.21"; }
      ];

      # DNS for the host (adjust to your resolvers)
      dns = [ "10.40.250.2" "1.1.1.1" ];
      domains = [ "~." ];
    };

    # =========================
    # VLAN 50 — Home Automation
    # =========================
    systemd.network.netdevs."ens18.50" = {
      netdevConfig = { Name = "ens18.50"; Kind = "vlan"; };
      vlanConfig.Id = 50;
    };

    systemd.network.networks."30-ens18.50" = {
      matchConfig.Name = "ens18.50";
      address = [ "10.40.50.21/24" ];

      routingPolicyRules = [
        { From = "10.40.50.21/32"; Table = 150; Priority = 1001; Family = "ipv4"; }
      ];

      routes = [
        { Destination = "0.0.0.0/0"; Gateway = "10.40.50.1"; Table = 150; PreferredSource = "10.40.50.21"; }
        { Destination = "10.40.50.0/24"; Table = 150; PreferredSource = "10.40.50.21"; }
        # (no main default here; Infra is your main)
      ];
    };

    # ---- rp_filter loose: required for multi-homed hosts ----
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = "2";
      "net.ipv4.conf.default.rp_filter" = "2";
      "net.ipv4.conf.ens18.rp_filter" = "2";
      "net.ipv4.conf.ens18.250.rp_filter" = "2";
      "net.ipv4.conf.ens18.50.rp_filter" = "2";
    };
  };
}