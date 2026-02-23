{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.nyx.modules.desktop.hypr;
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
  cava_start = pkgs.writeShellScriptBin "cava_start" ''
    sleep 1 && cava
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
    rofi -show drun q
  '';
  wallpaper_random = pkgs.writeShellScriptBin "wallpaper_random" ''
    #!/usr/bin/env bash
    if command -v swww >/dev/null 2>&1; then
      if ! swww query >/dev/null 2>&1; then
        swww-daemon > /dev/null 2>&1 &
        sleep 1
      fi
      paper=$(find ~/.config/wallpapers/ -name "*" | shuf -n1)
      swww img "$paper" --transition-type simple
      rm -f ~/active_paper
      cp "$paper" ~/active_paper
      if command -v wal >/dev/null 2>&1; then
        wal -i "$paper"
        mkdir -p ~/.config/btop/themes
        cp ~/.cache/wal/btop ~/.config/btop/themes/btop.theme
        rm -f ~/.config/kitty/colors-kitty.conf
        cp ~/.cache/wal/colors-kitty.conf ~/.config/kitty/colors-kitty.conf
        wbar_restart &
      fi
    fi
  '';
  wallpaper_default = pkgs.writeShellScriptBin "wallpaper_default" ''
    #!/usr/bin/env bash
    if command -v swww >/dev/null 2>&1; then
      if ! swww query >/dev/null 2>&1; then
        swww-daemon > /dev/null 2>&1 &
        sleep 1
      fi
      swww img ~/.config/wallpapers/wall0.png  --transition-type simple
      rm -f ~/active_paper
      cp ~/.config/wallpapers/wall0.png ~/active_paper
      if command -v wal >/dev/null 2>&1; then
        wal -i ~/.config/wallpapers/wall0.png
        mkdir -p ~/.config/btop/themes
        cp ~/.cache/wal/btop ~/.config/btop/themes/btop.theme
        rm -f ~/.config/kitty/colors-kitty.conf
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
          if ! swww query >/dev/null 2>&1; then
            swww-daemon > /dev/null 2>&1 &
            sleep 1
          fi
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
    ../../../../nixos/modules/desktop/hypr/hyprland-environment.nix
  ];

  options.nyx.modules.desktop.hypr = {
    enable = mkEnableOption "hypr configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nwg-displays
      wayland-protocols
      waybar
      swww
      mesa
      xwayland
      hyprpicker
      hypridle

      gnome-keyring
      acpi
      mpd
      killall
      #theming
      kdePackages.qt6ct
      libsForQt5.qt5ct
      libsForQt5.qtstyleplugin-kvantum
      pywal

      # --- Custom Scripts ---
      wbar_restart
      waybar_start_top
      waybar_start_bottom
      km_ka_restart
      wallpaper_random
      wallpaper_default
      init_colors
      rofiWindow
      cava_start
    ];

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    #wal template for hyprland
    home.file.".config/wal/templates/btop".source = ../../../../config/.config/wal/templates/btop;
    home.file.".config/wal/templates/colors-hyprland".source = ../../../../config/.config/wal/templates/colors-hyprland;
    #wallpapers directory
    xdg.configFile."wallpapers".source = ../../../../config/.config/wallpapers;
    xdg.configFile."hypr".source = ../../../../config/.config/hypr;
    xdg.configFile."waybar".source = ../../../../config/.config/waybar;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config = {
        common = {
          default = [
            "hyprland"
          ];
        };
      };
    };
    wayland.windowManager.hyprland = {
      # Plugins installed via AUR to avoid ABI mismatch with pacman's hyprland binary
      plugins = [];
      package = null;
      enable = true;
      systemd = {
        enable = true;
        variables = ["--all"];
      };
      xwayland.enable = true;
    };

    services.swaync = {
      enable = true;
      settings = {
        positionX = "right";
        positionY = "top";
        layer = "overlay";
        control-center-margin-top = 10;
        control-center-margin-bottom = 0;
        control-center-margin-right = 10;
        control-center-margin-left = 0;
        notification-icon-size = 64;
        timeout = 10;
        timeout-low = 5;
        timeout-critical = 0;
        transition-time = 200;
        hide-on-clear = false;
        hide-on-action = true;
        script-fail-notify = true;
        widgets = [ "inhibitors" "title" "dnd" "notifications" ];
        widget-config = {
          inhibitors = {
            text = "Inhibitors";
            button-text = "Clear All";
            clear-all-button = true;
          };
          title = {
            text = "Notifications";
            clear-all-button = true;
            button-text = "Clear All";
          };
          dnd = {
            text = "Do Not Disturb";
          };
        };
      };
      style = ''
        * {
          all: unset;
          font-family: "Source Sans Pro", sans-serif;
          font-size: 13px;
        }

        .control-center {
          background: #1e1e2a;
          border-radius: 10px;
          border: 1px solid #232323;
          color: #2596be;
          padding: 10px;
        }

        .notification-row {
          outline: none;
        }

        .notification-row:focus,
        .notification-row:hover {
          opacity: 0.9;
        }

        .notification {
          border-radius: 10px;
          border: 1px solid #232323;
          margin: 6px;
          padding: 0;
        }

        .notification-content {
          background: #1e1e2a;
          border-radius: 10px;
          padding: 10px;
          color: #2596be;
        }

        .low .notification-content {
          background: #232323;
          color: #2596be;
        }

        .critical .notification-content {
          background: #d64e4e;
          color: #f0e0e0;
        }

        .notification-default-action {
          border-radius: 10px;
        }

        .notification-action {
          border: 1px solid #232323;
          border-radius: 5px;
        }

        .close-button {
          background: #232323;
          border-radius: 100%;
          color: #2596be;
          min-width: 24px;
          min-height: 24px;
        }

        .close-button:hover {
          background: #d64e4e;
          color: #f0e0e0;
        }

        .blank-window {
          background: alpha(black, 0.0);
        }

        .widget-title {
          color: #2596be;
          font-size: 1.5rem;
          font-weight: bold;
          margin: 8px;
        }

        .widget-title > button {
          background: #232323;
          border: 1px solid #2596be;
          border-radius: 5px;
          color: #2596be;
          font-size: 0.9rem;
        }

        .widget-title > button:hover {
          background: #2596be;
          color: #1e1e2a;
        }

        .widget-dnd {
          margin: 8px;
        }

        .widget-dnd > switch {
          border-radius: 5px;
          border: 1px solid #232323;
          background: #232323;
        }

        .widget-dnd > switch:checked {
          background: #d64e4e;
        }

        .widget-dnd > switch slider {
          background: #2596be;
          border-radius: 5px;
        }
      '';
    };
  };
}
