{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.nyx.modules.desktop.hypr;
  plugins = inputs.hyprland-plugins.packages.${pkgs.system};
  wbar_restart = pkgs.writeShellScriptBin "wbar_restart" ''
    killall -q -9 -r waybar
    sleep .1
    waybar_start_top &
    waybar_start_bottom &
  '';
  waybar_start_top = pkgs.writeShellScriptBin "waybar_start_top" ''
    if command -v waybar >/dev/null 2>&1; then 
      waybar -c ~/.config/waybar/top.jsonc -s ~/.config/waybar/style.css
    fi
  '';
  waybar_start_bottom = pkgs.writeShellScriptBin "waybar_start_bottom" ''
    if command -v waybar >/dev/null 2>&1; then 
      waybar -c ~/.config/waybar/bottom.jsonc -s ~/.config/waybar/style.css
    fi
  '';
  rofiWindow = pkgs.writeShellScriptBin "rofiWindow" ''
    #!/usr/bin/env bash
    rofi -show drun 
  '';
  wallpaper_random = pkgs.writeShellScriptBin "wallpaper_random" ''
    #!/usr/bin/env bash
    if command -v swww >/dev/null 2>&1; then 
      paper=$(find ~/.config/wallpapers/ -name "*" | shuf -n1)
      swww img $paper --transition-type simple
      if command -v wal >/dev/null 2>&1; then 
        wal -i $paper
        cp ~/.cache/wal/btop ~/.config/btop/themes/btop.theme
        wbar_restart &
      fi
    fi
  '';
  wallpaper_default = pkgs.writeShellScriptBin "wallpaper_default" ''
    #!/usr/bin/env bash
    if command -v swww >/dev/null 2>&1; then
      swww img ~/.config/wallpapers/wall0.png  --transition-type simple
      if command -v wal >/dev/null 2>&1; then 
        wal -i ~/.config/wallpapers/wall0.png
        wbar_restart &
      fi
    fi
  '';

  init_colors = pkgs.writeShellScriptBin "init_colors" ''
    #!/usr/bin/env bash
    if wal &> /dev/null; then
      if !test -f ~/.cache/wal/colors-hyprland; then
        if command -v swww >/dev/null 2>&1; then
          swww img ~/.config/wallpapers/wall0.png  --transition-type simple
        fi
        wal -i ~/.config/wallpapers/wall0.png
        wbar_restart &
      fi
    fi
  '';
in
{
  imports = [
    ./hyprland-environment.nix
    ./dunst.nix
  ];

  options.nyx.modules.desktop.hypr = {
    enable = mkEnableOption "hypr configuration";
  };

  config = mkIf cfg.enable {


    home.packages = with pkgs; [
      swaylock-effects
      swayidle
      waybar
      dunst
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
      glfw-wayland
      pywal
      killall
      wbar_restart
      waybar_start_top
      waybar_start_bottom
      wallpaper_random
      wallpaper_default
      init_colors
      rofiWindow
    ];

    #wal template for hyprland
    # we call at each specific file so the directory is still writeable.
    home.file.".config/wal/templates/btop".source = ../../../../config/.config/wal/templates/btop;
    home.file.".config/wal/templates/colors-hyprland".source = ../../../../config/.config/wal/templates/colors-hyprland;
    #walpapers directory
    xdg.configFile."wallpapers".source = ../../../../config/.config/wallpapers;
    xdg.configFile."hypr".source = ../../../../config/.config/hypr;
    #swaylock
    xdg.configFile."swaylock".source = ../../../../config/.config/swaylock;
    #swayidle
    xdg.configFile."swayidle".source = ../../../../config/.config/swayidle;
    #waybar
    xdg.configFile."waybar".source = ../../../../config/.config/waybar;

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;
      plugins = with plugins; [ hyprbars ];
    };
  };
}
  
  
