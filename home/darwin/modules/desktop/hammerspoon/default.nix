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

    # I'm using individual files here to allow the .hammerspoon dir to be rw by default
    home.file.".hammerspoon/apps.lua".source = ../../../../config/.hammerspoon/apps.lua;
    home.file.".hammerspoon/commands.lua".source = ../../../../config/.hammerspoon/commands.lua;
    home.file.".hammerspoon/windows.lua".source = ../../../../config/.hammerspoon/windows.lua;
    home.file.".hammerspoon/init.lua".source = ../../../../config/.hammerspoon/init.lua;
    home.file.".hammerspoon/yabai.lua".source = ../../../../config/.hammerspoon/yabai.lua;
    home.file.".hammerspoon/Spoons/SpoonInstall.spoon".source = ../../../../config/.hammerspoon/Spoons/SpoonInstall.spoon;
  };
}