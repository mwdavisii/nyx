{ config, lib, pkgs, agenix, ... }:

with lib;
let
  cfg = config.nyx.modules.desktop.wallpaper;

  wallpaper_apply = pkgs.writeShellScriptBin "wallpaper_apply" ''
    #!/usr/bin/env bash
    # Shared helper: set wallpaper, generate pywal colors, apply color bridge
    file="$1"
    if [ -z "$file" ] || [ ! -f "$file" ]; then
      echo "Usage: wallpaper_apply <path-to-image>"
      exit 1
    fi
    osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$file\""
    wal -i "$file" 2> /dev/null
    command -v darwin-apply-colors >/dev/null 2>&1 && darwin-apply-colors
  '';

  wallpaper_default = pkgs.writeShellScriptBin "wallpaper_default" ''
    #!/usr/bin/env bash
    wallpaper_apply ~/.config/wallpapers/wall0.png
  '';

  wallpaper_sj = pkgs.writeShellScriptBin "wallpaper_sj" ''
    #!/usr/bin/env bash
    wallpaper_apply ~/.config/wallpapers/230599177-180001_PRIDE_VirtualBackground_v2-02.png
  '';

  wallpaper_random = pkgs.writeShellScriptBin "wallpaper_random" ''
    #!/usr/bin/env bash
    files=( ~/.config/wallpapers/* )
    num="''${#files[@]}"
    rand_idx=$(( RANDOM % num ))
    wallpaper_apply "''${files[rand_idx]}"
  '';

  wallpaper_choose = pkgs.writeShellScriptBin "wallpaper_choose" ''
    #!/usr/bin/env bash
    # Interactive wallpaper chooser with image previews via fzf + chafa
    WALLPAPER_DIR=~/.config/wallpapers

    chosen=$(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) \
      | sort \
      | ${pkgs.fzf}/bin/fzf \
          --preview '${pkgs.chafa}/bin/chafa -f sixel -s ''${FZF_PREVIEW_COLUMNS}x''${FZF_PREVIEW_LINES} {}' \
          --preview-window=right:60% \
          --prompt="Wallpaper> " \
          --header="Select a wallpaper (ESC to cancel)")

    [ -n "$chosen" ] && wallpaper_apply "$chosen"
  '';

in
{
  options.nyx.modules.desktop.wallpaper = {
    enable = mkEnableOption "Wallpapers";
  };

  config = mkIf cfg.enable {
     home.packages = with pkgs; [
      wallpaper_apply
      wallpaper_random
      wallpaper_default
      wallpaper_sj
      wallpaper_choose
      chafa
    ];
    home.file.".config/wal/templates/colors-kitty".source = ../../../../config/.config/wal/templates/colors-kitty;
    home.file.".config/wallpapers".source = ../../../../config/.config/wallpapers;
  };
}