{ config, lib, pkgs, ... }:
{
  home.packages = [ pkgs.nushell ];
  xdg.configFile."nushell" = {
    source = ../../config/.config/nushell;
    executable = true;
    recursive = true;
  };
}