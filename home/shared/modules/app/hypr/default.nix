{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.nyx.modules.app.hypr;
in
{
  imports = [
    ./hyprland-environment.nix
  ];

  options.nyx.modules.app.hypr = {
    enable = mkEnableOption "hypr configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      waybar
      swww
    ];
    xdg.configFile."hypr".source = ../../../../config/.config/hyper;
    #test later systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
    };

  };
}
  
  
