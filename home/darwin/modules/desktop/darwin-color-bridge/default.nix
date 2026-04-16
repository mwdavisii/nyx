{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.darwinColorBridge;

  applyColors = pkgs.writeShellScriptBin "darwin-apply-colors" ''
    #!/usr/bin/env bash
    # Reads pywal colors and applies them to sketchybar + wezterm.
    # Called by wallpaper_random / wallpaper_default after wal -i.

    SKETCHYBAR_COLORS="$HOME/.cache/wal/colors-sketchybar.sh"

    # --- Sketchybar ---
    if [ -f "$SKETCHYBAR_COLORS" ] && command -v sketchybar >/dev/null 2>&1; then
      source "$SKETCHYBAR_COLORS"
      sketchybar --bar color="$BAR_COLOR" \
        --default icon.color="$FOREGROUND" label.color="$FOREGROUND"

      # Update workspace items
      for sid in $(/opt/homebrew/bin/aerospace list-workspaces --all 2>/dev/null); do
        sketchybar --set space."$sid" \
          icon.color="$INACTIVE" \
          icon.highlight_color="$ACCENT"
      done

      # Update accent-colored items
      sketchybar --set media icon.color="$ACCENT"
      sketchybar --set clock icon.color="$ACCENT"

      echo "[darwin-apply-colors] sketchybar updated"
    fi

    # --- Wezterm (touch config to trigger reload) ---
    [ -f "$HOME/.config/wezterm/wezterm.lua" ] && touch "$HOME/.config/wezterm/wezterm.lua"

    echo "[darwin-apply-colors] done"
  '';
in
{
  options.nyx.modules.desktop.darwinColorBridge = {
    enable = mkEnableOption "darwin color bridge (pywal → sketchybar + terminals)";
  };

  config = mkIf cfg.enable {
    home.packages = [ applyColors ];

    # Deploy the sketchybar wal template so wal -i generates it
    home.file.".config/wal/templates/colors-sketchybar.sh".source =
      ../../../../config/.config/wal/templates/colors-sketchybar.sh;
  };
}
