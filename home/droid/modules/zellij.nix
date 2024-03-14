{ config, lib, pkgs, ... }:

{
    home.packages = [ pkgs.zellij ];
    xdg.configFile."zellij".source = ../../config/.config/zellij;
}
