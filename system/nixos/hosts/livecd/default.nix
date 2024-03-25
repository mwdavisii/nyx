{ config, pkgs, ... }:

{
  imports = [./system.nix]; 
  nyx = {
    modules = {
      user.home = ../worklt/home.nix;
    };

    secrets = {
      awsSSHKeys.enable = false;
      awsConfig.enable = false;
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