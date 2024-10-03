{ config, pkgs, ... }:

{
  imports = [./system.nix]; 
  nyx = {
    modules = {
      user.home = ./home.nix;
      system.yabai.enable = false;
    };

    secrets = {
      awsSSHKeys.enable = false;
      awsConfig.enable = false;
      userSSHKeys.enable = true;
      userPGPKeys.enable = true;
    };

    profiles = {
      macbook.enable = true;
    };
  };
}
