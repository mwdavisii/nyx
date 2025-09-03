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
        k3s.enable = true;
        ssh.enable = true;
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
