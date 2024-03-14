{ config, lib, pkgs, ... }:

with lib;
{
    home.file.".bash_profile".source = ../../../config/.bash_profile;
    home.file.".bashrc".source = ../../../config/.bashrc;
    home.file.".inputrc".source = ../../../config/.inputrc;
    home.file.".profile".source = ../../../config/.profile;
    xdg.configFile."shell".source = ../../../config/.config/shell;
}
