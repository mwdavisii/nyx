{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.nyx.modules.desktop.hypr;
  plugins = inputs.hyprland-plugins.packages.${pkgs.system};
in
{
  imports = [
    ./hyprland-environment.nix
  ];

  options.nyx.modules.desktop.hypr = {
    enable = mkEnableOption "hypr configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      waybar
      swww
      mesa
      xdg-desktop-portal-gtk
      xdg-desktop-portal
      acpi
      wayland-protocols
      mpd
      hyprpicker
      qt6ct
      qt5ct
      swaylock-effects
      swayidle
      #mesa-libGL
      #hyprlock
    ];
    xdg.configFile."hypr".source = ../../../../config/.config/hypr;
    xdg.configFile."swaylock".source = ../../../../config/.config/swaylock;
    xdg.configFile."swayidle".source = ../../../../config/.config/swayidle;
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;
      plugins = with plugins; [ hyprbars ];

    };

  };
}
  
  
