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
      wayland-protocols
      mesa
      mesa-libGL
      #hyprlock
    ];
    xdg.configFile."hypr".source = ../../../../config/.config/hypr;
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;
      plugins = with plugins; [ hyprbars ];

    };

  };
}
  
  
