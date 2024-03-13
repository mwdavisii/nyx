{ config, pkgs, userConf, inputs, hostname, ... }: 
with pkgs;
with userConf;
{
  system.stateVersion = "23.11";
  #programs.zsh.enable = true;
  #environment.pathsToLink = ["/share/zsh/"];
  #environment.shells = [pkgs.zsh];
  #security.sudo.wheelNeedsPassword = false;

  # Turn on flag for proprietary software
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };

    registry = {
      nixpkgs = {
        flake = inputs.nixpkgs;
      };
    };
  };
}