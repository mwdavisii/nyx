{ config, pkgs, ... }:

{
  # Manage home-manager with home-manager (inception)
  programs.home-manager.enable = true;
  home = {      
    stateVersion = "24.05";
    
    packages = with pkgs; [
      vim
      gcc
      clang-tools
      cmakeCurses
      cmake-format
      gnumake
      curl
      coreutils
    ];
  };
  imports = [
    ./modules
  ];
}