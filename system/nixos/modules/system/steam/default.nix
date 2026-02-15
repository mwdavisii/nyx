{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nyx.modules.system.steam;
in
{
  options.nyx.modules.system.steam = {
    enable = mkEnableOption "Enable Steam and Gaming Optimizations";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true; 
      gamescopeSession.enable = true;
    };
    programs.gamemode.enable = true;
    environment.systemPackages = with pkgs; [
      mangohud        # FPS Overlay
      protonup-qt     # GUI to install Proton GE (Fixes many games)
      gamescope       # Micro-compositor (Crucial for Hyprland resizing/alt-tab)
      lutris          # Launcher for non-Steam games
      heroic          # Launcher for Epic/GOG games
    ];
  };
}