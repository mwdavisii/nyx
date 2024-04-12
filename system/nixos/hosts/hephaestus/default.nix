{ config, pkgs, ... }:

{
  imports = [ ./system.nix ];
  nyx = {
    modules = {
      user.home = ./home.nix;
      system = {
        bluetooth.enable = true;
        amd.enable = true;
        garbagecollection.enable = true;
        hyprlogin.enable = true;
        opengl.enable = true;
        centraltimezone.enable = true;
        yubilogin.enable = true;
        kmonad.enable = true;
      };
    };
    
    secrets = {
      awsSSHKeys.enable = false;
      awsConfig.enable = true;
      userSSHKeys.enable = true;
      userPGPKeys.enable = true;
    };

    profiles = {
      desktop = {
        enable = true;
      };
    };
  };
}
