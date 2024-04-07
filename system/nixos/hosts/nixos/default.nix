{ config, pkgs, ... }:

{

  nyx = {
    modules = {
      user.home = ../../shared/home.nix;
      system = {
        wsl2.enable = true;
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