{ config, pkgs, ... }:

{
  imports = [../../shared/system]; 
  nyx = {
    modules = {
      user.home = ../../shared/home.nix;
    };

    secrets = {
      awsConfig.enable = true;
      awsSSHKeys.enable = false;  
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