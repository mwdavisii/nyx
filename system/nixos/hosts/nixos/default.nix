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