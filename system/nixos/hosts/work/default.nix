{ config, pkgs, ... }:

{
  nyx = {
    modules = {
      user.home = ../../shared/home.nix;
      system = {
        wsl2.enable = true;
        docker.enable = true;
      };
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