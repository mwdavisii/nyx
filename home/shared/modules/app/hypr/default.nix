{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.nyx.modules.app.hypr;
  plugins = inputs.hyprland-plugins.packages.${pkgs.system};
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
      #hyprlock
    ];
    xdg.configFile."hypr".source = ../../../../config/.config/hypr;
    #test later systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;
      plugins = with plugins; [ hyprbars ];

    };

  };
}
  
  
