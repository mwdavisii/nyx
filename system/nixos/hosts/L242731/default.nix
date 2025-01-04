{ config, pkgs, ... }:

{
  imports = [ ./system.nix ];
  nyx = {
    modules = {
      user.home = ./home.nix;
      system = {
        bluetooth.enable = true;
        garbagecollection.enable = true;
        hyprlogin.enable = true;
        opengl.enable = true;
        openvpn.enable = true;
        openrgb.enable = true;
        centraltimezone.enable = true;
        yubilogin.enable = true;
        hyprland.enable = true;
        kmonad.enable = true;
      };
    };

    secrets = {
      awsSSHKeys.enable = false;
      awsConfig.enable = false;
      userSSHKeys.enable = true;
      userPGPKeys.enable = true;
      workvpn.enable = false;
    };

    profiles = {
      desktop = {
        enable = true;
      };
    };
  };
}
