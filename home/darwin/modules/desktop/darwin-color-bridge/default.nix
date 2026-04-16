{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.darwinColorBridge;

  applyColors = pkgs.writeShellScriptBin "darwin-apply-colors" ''
    #!/usr/bin/env bash
    # Reads pywal colors and applies them to sketchybar + yabai + wezterm.
    # Called by wallpaper_random / wallpaper_default after wal -i.

    COLORS_JSON="$HOME/.cache/wal/colors.json"
    SKETCHYBAR_COLORS="$HOME/.cache/wal/colors-sketchybar.sh"

    if [ ! -f "$COLORS_JSON" ]; then
      echo "[darwin-apply-colors] no colors.json, skipping"
      exit 0
    fi

    # --- Sketchybar ---
    if [ -f "$SKETCHYBAR_COLORS" ] && command -v sketchybar >/dev/null 2>&1; then
      source "$SKETCHYBAR_COLORS"
      sketchybar --bar color="$BAR_COLOR" \
        --default icon.color="$FOREGROUND" label.color="$FOREGROUND"

      # Update workspace items
      for sid in $(yabai -m query --spaces | ${pkgs.jq}/bin/jq -r '.[].index' 2>/dev/null); do
        sketchybar --set space."$sid" \
          icon.color="$INACTIVE" \
          icon.highlight_color="$ACCENT"
      done

      # Update accent-colored items
      sketchybar --set media icon.color="$ACCENT"
      sketchybar --set clock icon.color="$ACCENT"

      echo "[darwin-apply-colors] sketchybar updated"
    fi

    # --- Yabai border colors ---
    if command -v yabai >/dev/null 2>&1; then
      BG=$(${pkgs.jq}/bin/jq -r '.colors.color4' "$COLORS_JSON" | tr -d '#')
      NORMAL_BG=$(${pkgs.jq}/bin/jq -r '.colors.color0' "$COLORS_JSON" | tr -d '#')
      yabai -m config active_window_border_color "0xE0''${BG}"
      yabai -m config normal_window_border_color "0x40''${NORMAL_BG}"
      echo "[darwin-apply-colors] yabai borders updated"
    fi

    # --- Wezterm (touch config to trigger reload) ---
    [ -f "$HOME/.config/wezterm/wezterm.lua" ] && touch "$HOME/.config/wezterm/wezterm.lua"

    echo "[darwin-apply-colors] done"
  '';
in
{
  options.nyx.modules.desktop.darwinColorBridge = {
    enable = mkEnableOption "darwin color bridge (pywal → sketchybar + yabai + terminals)";
  };

  config = mkIf cfg.enable {
    home.packages = [ applyColors ];

    # Deploy the sketchybar wal template so wal -i generates it
    home.file.".config/wal/templates/colors-sketchybar.sh".source =
      ../../../../config/.config/wal/templates/colors-sketchybar.sh;
  };
}
