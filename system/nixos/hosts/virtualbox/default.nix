{ config, pkgs, ... }:

{
  imports = [./system.nix]; 
  nyx = {
    modules = {
      user.home = ../../shared/home.nix;
      system = {
        bluetooth.enable = true;
        garbagecollection.enable = true;
        hyprlogin.enable = true;
        opengl.enable = true;
        centraltimezone.enable = true;
        yubilogin.enable = true;
      };
    };

    secrets = {
      awsSSHKeys.enable = false;
      awsConfig.enable = true;
      userSSHKeys.enable = false;
      userPGPKeys.enable = false;
    };

    profiles = {
      desktop = {
        enable = true;
      };
    };
  };
}