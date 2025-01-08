{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.nyx.modules.desktop.hypr;
  plugins = inputs.hyprland-plugins.packages.${pkgs.system};
  km_ka_restart = pkgs.writeShellScriptBin "km_ka_restart" ''
    killall -q -9 -r kmonad
    killall -q -9 -r kanshi
    sleep .5
    nohup kanshi &
    nohup ~/.config/kmonad/selectKBD.sh &
  '';
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
      cp $paper ~/active_paper
      if command -v wal >/dev/null 2>&1; then 
        wal -i $paper
        cp ~/.cache/wal/btop ~/.config/btop/themes/btop.theme
        cp ~/.cache/wal/colors-kitty.conf ~/.config/kitty/colors-kitty.conf
        wbar_restart &
      fi
    fi
  '';
  wallpaper_default = pkgs.writeShellScriptBin "wallpaper_default" ''
    #!/usr/bin/env bash
    if command -v swww >/dev/null 2>&1; then
      swww img ~/.config/wallpapers/wall0.png  --transition-type simple
      cp $paper ~/active_paper
      if command -v wal >/dev/null 2>&1; then 
        wal -i ~/.config/wallpapers/wall0.png
        cp ~/.cache/wal/btop ~/.config/btop/themes/btop.theme
        cp ~/.cache/wal/colors-kitty.conf ~/.config/kitty/colors-kitty.conf
        wbar_restart &
      fi
    fi
  '';

  init_colors = pkgs.writeShellScriptBin "init_colors" ''
    #!/usr/bin/env bash
    if command -v wal >/dev/null 2>&1; then
      if ! test -f ~/.cache/wal/colors-hyprland; then
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
  ];

  options.nyx.modules.desktop.hypr = {
    enable = mkEnableOption "hypr configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nwg-displays
      wayland-protocols
      waybar
      dunst
      swww
      mesa
      xwayland
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      xdg-desktop-portal
      gnome-keyring
      acpi
      mpd
      hyprpicker
      qt6ct
      libsForQt5.qt5ct
      glfw-wayland
      pywal
      killall
      wbar_restart
      waybar_start_top
      waybar_start_bottom
      km_ka_restart
      wallpaper_random
      wallpaper_default
      init_colors
      rofiWindow
      hyprlock
      hypridle
    ];

    #wal template for hyprland
    # we call at each specific file so the directory is still writeable.
    home.file.".config/wal/templates/btop".source = ../../../../config/.config/wal/templates/btop;
    home.file.".config/wal/templates/colors-hyprland".source = ../../../../config/.config/wal/templates/colors-hyprland;
    #walpapers directory
    xdg.configFile."wallpapers".source = ../../../../config/.config/wallpapers;
    xdg.configFile."hypr".source = ../../../../config/.config/hypr;
    xdg.configFile."waybar".source = ../../../../config/.config/waybar;

    wayland.windowManager.hyprland = {
      plugins = [
        #plugins.hyprexpo
        plugins.hyprbars
        plugins.hyprwinwrap
        plugins.hyprtrails
      ];
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;

    };

    services.dunst = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      settings = {
        global = {
          rounded = "yes";
          origin = "top-right";
          monitor = "0";
          alignment = "left";
          vertical_alignment = "center";
          width = "400";
          height = "400";
          scale = 0;
          gap_size = 0;
          progress_bar = true;
          transparency = 0;
          text_icon_padding = 0;
          separator_color = "frame";
          sort = "yes";
          idle_threshold = 120;
          line_height = 0;
          markup = "full";
          show_age_threshold = 60;
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          sticky_history = "yes";
          history_length = 20;
          always_run_script = true;
          corner_radius = 10;
          follow = "mouse";
          font = "Source Sans Pro 10";
          format = "<b>%s</b>\\n%b"; #format = "<span foreground='#f3f4f5'><b>%s %p</b></span>\n%b"
          frame_color = "#232323";
          frame_width = 1;
          offset = "15x15";
          horizontal_padding = 10;
          icon_position = "left";
          indicate_hidden = "yes";
          min_icon_size = 0;
          max_icon_size = 64;
          mouse_left_click = "do_action, close_current";
          mouse_middle_click = "close_current";
          mouse_right_click = "close_all";
          padding = 10;
          plain_text = "no";
          separator_height = 2;
          show_indicators = "yes";
          shrink = "no";
          word_wrap = "yes";
          browser = "/usr/bin/env librewolf -new-tab";
        };
        fullscreen_delay_everything = { fullscreen = "delay"; };

        urgency_critical = {
          background = "#d64e4e";
          foreground = "#f0e0e0";
        };

        urgency_low = {
          background = "#232323";
          foreground = "#2596be";
        };

        urgency_normal = {
          background = "#1e1e2a";
          foreground = "#2596be";
        };
      };
    };
  };
}
  
  
