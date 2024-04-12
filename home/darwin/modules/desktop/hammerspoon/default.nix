{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfg = config.nyx.modules.desktop.hammerspoon;
  #hammerspoon = (pkgs.callPackage ../../../../../nix/pkgs/hammerspoon {} // lib // pkgs);
in
{
  options.nyx.modules.desktop.hammerspoon = {
    enable = mkEnableOption "hammerspoon";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
     hammerspoon
    ];
    #programs.hammerspoon = {
    #    enable = true;
    #    package = hammerspoon;
    #};
    # place the default hammerspoon file - this points to the folder under ~/.config/hammerspoon
    home.file.".hammerspoon".source = ../../../../config/.hammerspoon;
  };
}