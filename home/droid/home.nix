{ config, pkgs, ... }:

{
  # Manage home-manager with home-manager (inception)
  programs.home-manager.enable = true;
  home = {      
    stateVersion = "23.11";
    
    packages = with pkgs; [
      vim
      gcc
      clang-tools
      cmakeCurses
      cmake-format
      gnumake
    ];
  };
  imports = [
    ./home/droid/modules
  ];
}