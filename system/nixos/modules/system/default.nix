{ config, lib, pkgs, modulesPath, hostName, userConf, ... }:


{
  imports = [ 
    ./bluetooth.nix 
    ./env-vars-amd.nix
    ./env-vars-nvidia.nix
    ./gc.nix
    ./hyprlogin.nix 
    ./packages.nix
    ./opengl.nix
    ./timezones.nix
    ./yubilogin.nix
  ];
}
