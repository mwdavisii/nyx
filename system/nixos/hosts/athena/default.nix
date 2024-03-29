{ config, pkgs, ... }:

{
  imports = [ ./system.nix ];
  nyx = {
    modules = {
      user.home = ./home.nix;
    };

    secrets = {
      awsSSHKeys.enable = false;
      awsConfig.enable = false;
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
