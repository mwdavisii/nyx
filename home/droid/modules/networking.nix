{ config, lib, pkgs, ... }:
{
    home.packages = with pkgs;[ 
        coreutils-full
        inetutils
    ];
}