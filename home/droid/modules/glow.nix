{ config, lib, pkgs, ... }:

{
    home.packages = [ pkgs.glow ];
    xdg.configFile."glow".source = ../../config/.config/glow;
}
