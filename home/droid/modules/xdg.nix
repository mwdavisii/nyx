{ config, lib, pkgs, ... }:

{
    xdg = {
      enable = true;
      mime.enable = pkgs.stdenv.isLinux;
    };
}

