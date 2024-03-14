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
  permittedInsecurePackages = [
    "nix-2.15.3"
  ];
  
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    registry = {
      nixpkgs = {
        flake = inputs.nixpkgs;
      };
    };
  };
}