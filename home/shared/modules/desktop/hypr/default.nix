{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.nyx.modules.desktop.hypr;
  hyprPlugins = inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system};
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
  show_desktop = pkgs.writeShellScriptBin "show_desktop" ''
    STATE_FILE="/tmp/hypr_show_desktop_$(hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r '.id')"
    if [ -f "$STATE_FILE" ]; then
      # Restore: move windows back from special workspace
      while hyprctl clients -j | ${pkgs.jq}/bin/jq -e '.[] | select(.workspace.name == "special:desktop_stash")' > /dev/null 2>&1; do
        hyprctl dispatch togglespecialworkspace desktop_stash
        hyprctl dispatch movetoworkspacesilent "$(cat "$STATE_FILE")"
        hyprctl dispatch togglespecialworkspace desktop_stash
      done
      rm "$STATE_FILE"
    else
      # Stash: move all windows to special workspace
      WS_ID=$(hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r '.id')
      echo "$WS_ID" > "$STATE_FILE"
      WIN_COUNT=$(hyprctl clients -j | ${pkgs.jq}/bin/jq "[.[] | select(.workspace.id == $WS_ID and .class != \"kitty-bg\")] | length")
      for i in $(seq 1 "$WIN_COUNT"); do
        hyprctl dispatch movetoworkspacesilent special:desktop_stash
      done
    fi
  '';
  cava_start = pkgs.writeShellScriptBin "cava_start" ''
    sleep 1 && cava
  '';
  cava_toggle = pkgs.writeShellScriptBin "cava_toggle" ''
    if pkill -f "kitty.*kitty-bg"; then
      exit 0
    else
      kitty --class="kitty-bg" --override background_opacity=0.0 cava_start
    fi
  '';
  waybar_start_top = pkgs.writeShellScriptBin "waybar_start_top" ''
    if command -v waybar >/dev/null 2>&1; then
      waybar -c ~/.config/waybar/top.jsonc -s ~/.config/waybar/style.css >/dev/null 2>&1
    fi
  '';
  waybar_start_bottom = pkgs.writeShellScriptBin "waybar_start_bottom" ''
    if command -v waybar >/dev/null 2>&1; then
      waybar -c ~/.config/waybar/bottom.jsonc -s ~/.config/waybar/style.css >/dev/null 2>&1
    fi
  '';
  rofiWindow = pkgs.writeShellScriptBin "rofiWindow" ''
    #!/usr/bin/env bash
    rofi -show drun q
  '';
  rofiPowerMenu = pkgs.writeShellScriptBin "rofiPowerMenu" ''
    #!/usr/bin/env bash
    options="󰌾 Lock\n󰗼 Logout\n󰤄 Suspend\n󰋊 Hibernate\n󰜉 Reboot\n󰐥 Shutdown"
    chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power" -theme-str 'window {width: 250px;} listview {lines: 6;}')
    case "$chosen" in
      "󰌾 Lock")       hyprlock ;;
      "󰗼 Logout")     loginctl terminate-user "$USER" ;;
      "󰤄 Suspend")    systemctl suspend ;;
      "󰋊 Hibernate")  systemctl hibernate ;;
      "󰜉 Reboot")     systemctl reboot ;;
      "󰐥 Shutdown")   systemctl poweroff ;;
    esac
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
        cp ~/.cache/wal/cava ~/.config/cava/config
        pkill -USR2 cava 2>/dev/null || true
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
      swww img ~/.config/wallpapers/liquid1.png  --transition-type simple
      rm -f ~/active_paper
      cp ~/.config/wallpapers/wall0.png ~/active_paper
      if command -v wal >/dev/null 2>&1; then
        wal -i ~/.config/wallpapers/wall0.png
        mkdir -p ~/.config/btop/themes
        cp ~/.cache/wal/btop ~/.config/btop/themes/btop.theme
        cp ~/.cache/wal/cava ~/.config/cava/config
        pkill -USR2 cava 2>/dev/null || true
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
        mkdir -p ~/.config/btop/themes
        cp ~/.cache/wal/btop ~/.config/btop/themes/btop.theme
        cp ~/.cache/wal/cava ~/.config/cava/config
        pkill -USR2 cava 2>/dev/null || true
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
    gpuPackages = mkOption {
      type = types.bool;
      default = true;
      description = "Install GPU-dependent packages (waybar, swww, etc.) via Nix. Set false on non-NixOS where system GPU drivers are used.";
    };
    plugins = mkOption {
      type = types.bool;
      default = true;
      description = "Install Hyprland plugins from hyprland-plugins input. Set false on Arch where plugins come from AUR.";
    };
    ttyLaunch = mkOption {
      type = types.bool;
      default = false;
      description = "Auto-launch Hyprland from zsh on TTY1 (for systems without a display manager).";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
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
      rofiPowerMenu
      cava_start
      cava_toggle
      show_desktop
    ] ++ lib.optionals cfg.gpuPackages [
      nwg-displays
      wayland-protocols
      waybar
      swww
      mesa
      xwayland
      hyprpicker
    ];

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    #wal templates (superset — all 5)
    home.file.".config/wal/templates/btop".source = ../../../../config/.config/wal/templates/btop;
    home.file.".config/wal/templates/cava".source = ../../../../config/.config/wal/templates/cava;
    home.file.".config/wal/templates/colors-hyprland".source = ../../../../config/.config/wal/templates/colors-hyprland;
    home.file.".config/wal/templates/colors-kitty".source = ../../../../config/.config/wal/templates/colors-kitty;
    home.file.".config/wal/templates/colors-waybar".source = ../../../../config/.config/wal/templates/colors-waybar;
    home.file.".config/wal/templates/dunstrc".source = ../../../../config/.config/wal/templates/dunstrc;
    #wallpapers directory
    xdg.configFile."wallpapers".source = ../../../../config/.config/wallpapers;
    xdg.configFile."hypr".source = ../../../../config/.config/hypr;
    xdg.configFile."waybar".source = ../../../../config/.config/waybar;

    # Seed the wal color cache from the template so Hyprland's
    # `source=~/.cache/wal/colors-hyprland` doesn't fail on first boot
    # (init_colors runs exec-once which is too late — source= is parsed at startup).
    home.activation.seedWalColors = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f "$HOME/.cache/wal/colors-hyprland" ]; then
        $DRY_RUN_CMD mkdir -p "$HOME/.cache/wal"
        $DRY_RUN_CMD cp "$HOME/.config/wal/templates/colors-hyprland" "$HOME/.cache/wal/colors-hyprland"
        $DRY_RUN_CMD chmod 644 "$HOME/.cache/wal/colors-hyprland"
      fi
    '';

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

    # Launch Hyprland automatically after login on tty1 (no display manager)
    nyx.modules.shell.zsh.profileExtra = mkIf cfg.ttyLaunch ''
      if [ -z "$DISPLAY" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
        # Ensure Nix profile is sourced before launching Hyprland
        if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi
        # Source home-manager session variables so they reach Hyprland and all child processes
        if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        fi
        exec start-hyprland
      fi
    '';

    wayland.windowManager.hyprland = {
      plugins = if cfg.plugins then [
        hyprPlugins.hyprexpo
        hyprPlugins.hyprbars
        hyprPlugins.hyprwinwrap
      ] else [];
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
