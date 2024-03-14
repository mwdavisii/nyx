{ config, lib, pkgs, ... }:

with lib;
let
  additionalPkgs = with pkgs;
    [
      vimv # Batch rename files with vim
      ueberzug
    ];
in
{

  home.packages = [ pkg.lf ] ++ additionalPkgs;
  xdg.configFile."lf" = {
    source = ../../../config/.config/lf;
    executable = true;
    recursive = true;
  };
}
