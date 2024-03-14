{ config, lib, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    package = pkgs.starship;
  };

  xdg.configFile."starship".source = ../../../config/.config/starship;
}
