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
  bluetooth_toggle = pkgs.writeShellScriptBin "bluetooth_toggle" ''
    #!/usr/bin/env bash
    if bluetoothctl show | grep -q "Powered: yes"; then
      bluetoothctl power off
    else
      bluetoothctl power on
    fi
  '';
  gamepad_idle_inhibit = pkgs.writeShellScriptBin "gamepad_idle_inhibit" ''
    # Holds a systemd idle inhibitor while any gamepad/controller is connected.
    # hypridle respects systemd --what=idle inhibitors, preventing lock + sleep.
    INHIBIT_PID=""

    acquire() {
      [ -n "$INHIBIT_PID" ] && return
      systemd-inhibit --what=idle --who="gamepad-idle-inhibit" \
        --why="Controller connected" --mode=block sleep infinity &
      INHIBIT_PID=$!
    }

    release() {
      [ -z "$INHIBIT_PID" ] && return
      kill "$INHIBIT_PID" 2>/dev/null
      INHIBIT_PID=""
    }

    trap release EXIT INT TERM

    while true; do
      if compgen -G "/dev/input/js*" > /dev/null 2>&1; then
        acquire
      else
        release
      fi
      sleep 5
    done
  '';
  qs_restart = pkgs.writeShellScriptBin "qs_restart" ''
    killall -q quickshell
    sleep 0.2
    ambxst &
  '';
  wallpaper_random = pkgs.writeShellScriptBin "wallpaper_random" ''
    #!/usr/bin/env bash
    paper=$(find ~/.config/wallpapers/ -name "*" -type f | shuf -n1)
    if [ -n "$paper" ]; then
      if command -v swww >/dev/null 2>&1; then
        if ! swww query >/dev/null 2>&1; then
          swww-daemon > /dev/null 2>&1 &
          sleep 1
        fi
        swww img "$paper" --transition-type simple
      fi
      rm -f ~/active_paper
      cp "$paper" ~/active_paper
      wal -i "$paper" -q -n
      touch ~/.config/wezterm/wezterm.lua
    fi
  '';
  wallpaper_default = pkgs.writeShellScriptBin "wallpaper_default" ''
    #!/usr/bin/env bash
    paper=~/.config/wallpapers/liquid1.jpg
    if command -v swww >/dev/null 2>&1; then
      if ! swww query >/dev/null 2>&1; then
        swww-daemon > /dev/null 2>&1 &
        sleep 1
      fi
      swww img "$paper" --transition-type simple
      rm -f ~/active_paper
      cp "$paper" ~/active_paper
      wal -i "$paper" -q -n
      touch ~/.config/wezterm/wezterm.lua
    fi
  '';
in
{
  imports = [
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
    home.sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "google-chrome-stable";
      TERMINAL = "kitty";
      SDL_JOYSTICK_HIDAPI_XBOX_ONE = "0";
      SDL_JOYSTICK_HIDAPI_XBOX = "0";
      SDL_GAMECONTROLLERCONFIG = "050000005e0400008e02000030110000,Xbox Wireless Controller,a:b0,b:b1,x:b2,y:b3,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a3,righty:a4,lefttrigger:a2,righttrigger:a5,platform:Linux,";
      CLUTTER_BACKEND = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      HYPRCURSOR_THEME = "MyCursor";
      HYPRCURSOR_SIZE = "24";
      XCURSOR_THEME = "MyCursor";
      XCURSOR_SIZE = "24";
    };

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
      qs_restart
      gamepad_idle_inhibit
      bluetooth_toggle
      km_ka_restart
      wallpaper_random
      wallpaper_default
      cava_start
      cava_toggle
      show_desktop
    ] ++ lib.optionals cfg.gpuPackages [
      nwg-displays
      wayland-protocols
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
    home.file.".config/wal/templates/colors-wezterm.lua".source = ../../../../config/.config/wal/templates/colors-wezterm.lua;
    home.file.".config/wal/templates/dunstrc".source = ../../../../config/.config/wal/templates/dunstrc;
    home.file.".config/wal/templates/swaync".source = ../../../../config/.config/wal/templates/swaync;
    #wallpapers directory
    xdg.configFile = lib.mkMerge [
      {
        "wallpapers".source = ../../../../config/.config/wallpapers;
        # ambxst/config is NOT symlinked here — it must be writable so ambxst
        # can persist preset selections. Seeded via home.activation.seedAmbxstConfig below.
        # Symlink individual hypr files rather than the whole directory so that
        # ~/.config/hypr/ is a real writable directory (Ambxst may write there)
        "hypr/hyprland.conf".source = ../../../../config/.config/hypr/hyprland.conf;
        "hypr/hyprlock.conf".source = ../../../../config/.config/hypr/hyprlock.conf;
        "hypr/monitors.conf".source = ../../../../config/.config/hypr/monitors.conf;
        "hypr/startup.conf".source = ../../../../config/.config/hypr/startup.conf;
      }
      (lib.mkIf cfg.gpuPackages {
        "waybar".source = ../../../../config/.config/waybar;
      })
      # Ambxst shell config is seeded via home.activation.seedAmbxstConfig (writable copy, not symlink)
    ];

    # Seed wallpapers into ~/Pictures/wallpapers/ as real files so ambxst's
    # `find` scan works (it doesn't follow Nix store directory symlinks).
    # Uses -n so user-added wallpapers are preserved and existing files aren't overwritten.
    home.activation.seedWallpapers = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p "$HOME/Pictures/wallpapers"
      for f in "${../../../../config/.config/wallpapers}"/*; do
        [ -f "$f" ] || continue
        dst="$HOME/Pictures/wallpapers/$(basename "$f")"
        [ -e "$dst" ] || $DRY_RUN_CMD cp "$f" "$dst"
      done
    '';

    # Seed ambxst config files as real writable copies (not symlinks) so ambxst
    # can write preset changes. Uses --no-clobber so rebuilds don't overwrite
    # whatever the user last selected.
    home.activation.seedAmbxstConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.config/ambxst/config"
      for f in ai.json bar.json compositor.json dock.json system.json theme.json workspaces.json; do
        src="${../../../../config/.config/ambxst/config}/$f"
        dst="$HOME/.config/ambxst/config/$f"
        if [ ! -f "$dst" ] || [ ! -w "$dst" ]; then
          $DRY_RUN_CMD cp --remove-destination "$src" "$dst"
          $DRY_RUN_CMD chmod 644 "$dst"
        fi
      done
    '';

    # Seed ~/.cache/ambxst/wallpapers.json with the correct wallPath on first run.
    # Only creates the file if it doesn't exist, so user changes are preserved.
    # The path must be absolute (QML doesn't expand ~ or $HOME when passed to find).
    home.activation.seedAmbxstWallpapersJson = lib.hm.dag.entryAfter ["writeBoundary"] ''
      _ambxstCache="$HOME/.cache/ambxst"
      _wallpapersJson="$_ambxstCache/wallpapers.json"
      if [ ! -f "$_wallpapersJson" ]; then
        $DRY_RUN_CMD mkdir -p "$_ambxstCache"
        if [ -z "$DRY_RUN_CMD" ]; then
          printf '{\n    "activeColorPreset": "",\n    "currentWall": "",\n    "matugenScheme": "scheme-tonal-spot",\n    "perScreenWallpapers": {},\n    "tintEnabled": false,\n    "wallPath": "%s/Pictures/wallpapers"\n}\n' "$HOME" > "$_wallpapersJson"
        fi
      fi
    '';

    # Seed the wal color cache from the template so Hyprland's
    # `source=~/.cache/wal/colors-hyprland` doesn't fail on first boot
    # (init_colors runs exec-once which is too late — source= is parsed at startup).
    home.activation.seedWalColors = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f "$HOME/.cache/wal/colors-hyprland" ] || [ ! -w "$HOME/.cache/wal/colors-hyprland" ]; then
        $DRY_RUN_CMD mkdir -p "$HOME/.cache/wal"
        $DRY_RUN_CMD cp --remove-destination "$HOME/.config/wal/templates/colors-hyprland" "$HOME/.cache/wal/colors-hyprland"
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
        notification-window-width = 500;
        control-center-width = 500;
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
      # Style is generated dynamically by pywal via the swaync wal template.
      # ambxst-color-bridge copies ~/.cache/wal/swaync → ~/.config/swaync/style.css
      # and reloads swaync on each wallpaper change.
    };
  };
}
