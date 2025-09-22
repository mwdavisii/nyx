{ config, pkgs, ... }:

{
  imports = [ ./system.nix ];
  nyx = {
    modules = {
      user.home = ./home.nix;
      system = {
        bluetooth.enable = false;
        amd.enable = false;
        garbagecollection.enable = true;
        hyprlogin.enable = false;
        acceleratedgraphics.enable = false;
        centraltimezone.enable = true;
        yubilogin.enable = false;
        kmonad.enable = false;
        hyprland.enable = false;
        k3s = {
          enable = true;
          interface = "ens18";
          address = "10.40.250.100";
            "hydra"                 # short hostname
            "hydra.mwdavisii.com"   # FQDN you already have
            "hydra.local"           # mDNS/host-only name you already have
            "10.40.250.100"         # node IP you already have
            "10.40.250.221"         # (if/when you put a VIP/LB in front)
            "10.43.0.1"             # clusterIP for kubernetes.default (if using it)
            "127.0.0.1"             # you already have; harmless
          networkingBackend = "cilium";
          taintControlPlane = true;
          role = "server";
        };
        ssh.enable = true;
        qemu.enable = true;
      };
    };
    
    secrets = {
      awsSSHKeys.enable = false;
      awsConfig.enable = false;
      userSSHKeys.enable = true;
      userPGPKeys.enable = true;
    };
    profiles = {
      desktop = {
        enable = false;
      };
    };
  };
}

