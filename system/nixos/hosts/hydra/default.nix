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
          tlsSans = [ "hydra.mwdavisii.com" "hydra.local" "10.40.250.100" "127.0.0.1"];
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

