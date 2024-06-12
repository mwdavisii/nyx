{ config, lib, pkgs, agenix, ... }:

with lib;
let 
  cfg = config.nyx.modules.desktop.wallpaper;
  wallpaper_default = pkgs.writeShellScriptBin "wallpaper_default" ''
      #!/usr/bin/env bash
      file=~/.config/wallpapers/wall0.png
      osascript -e "tell application \"System Events\" to tell every desktop to set picture to \""''${file}\"" as POSIX file"
      wal -i "''${rand_file}" 2> /dev/null
      '';
    

  wallpaper_random = pkgs.writeShellScriptBin "wallpaper_random" ''
    #!/usr/bin/env bash
    files=( ~/.config/wallpapers/* )
    num="''${#files[@]}"
    rand_idx=$(( RANDOM % num ))
    rand_file="''${files[rand_idx]}"
    osascript -e "tell application \"System Events\" to tell every desktop to set picture to \""''${rand_file}\"" as POSIX file"
    wal -i "''${rand_file}" 2> /dev/null
  '';
in
{
  options.nyx.modules.desktop.wallpaper = {
    enable = mkEnableOption "Wallpapers";
  };

  config = mkIf cfg.enable {
     home.packages = with pkgs; [
      wallpaper_random
      wallpaper_default
    ];
    home.file.".config/wal/templates/colors-kitty".source = ../../../../config/.config/wal/templates/colors-kitty;
    home.file.".config/wallpapers".source = ../../../../config/.config/wallpapers;  
  };
}