{ config, pkgs, ... }:

{
  imports = [../../shared/system.nix]; 
  nyx = {
    modules = {
      user.home = ./home.nix;
    };

    secrets = {
      awsSSHKeys.enable = true;
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