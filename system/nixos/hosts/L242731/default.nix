{ config, pkgs, ... }:

{
  imports = [ ./system.nix ];
  nyx = {
    modules = {
      user.home = ./home.nix;
      system = {
        acceleratedgraphics.enable = true;
        bluetooth.enable = true;
        garbagecollection.enable = true;
        hyprlogin.enable = true;
        openvpn.enable = false;
        openrgb.enable = false;
        centraltimezone.enable = true;
        yubilogin.enable = false;
        hyprland.enable = true;
        kmonad.enable = true;
        docker.enable = true;
        #kanshi.enable = true;
      };
    };

    secrets = {
      awsSSHKeys.enable = false;
      awsConfig.enable = false;
      userSSHKeys.enable = true;
      userPGPKeys.enable = true;
      workvpn.enable = true;
    };

    profiles = {
      desktop = {
        enable = true;
      };
    };
  };
}
