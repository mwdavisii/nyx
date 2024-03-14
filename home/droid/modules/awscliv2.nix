{ config, lib, pkgs, agenix, ... }:

{
    home.packages = with pkgs;[ awscli2 ];
}