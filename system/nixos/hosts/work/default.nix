{ config, pkgs, ... }:

{
  imports = [../../shared/wslsystem.nix]; 
  nyx = {
    modules = {
      user.home = ../../shared/home.nix;
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