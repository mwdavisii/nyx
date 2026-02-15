{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.shell.wal;
    theme_term = pkgs.writeShellScriptBin "theme_term" ''
    #!/usr/bin/env bash
    WIN_PATH_RAW=$(reg.exe query "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper | grep Wallpaper | awk '{print $3}')
    WSL_PATH=$(echo "$WIN_PATH_RAW" | tr -d '\r' | sed 's|\\|/|g' | sed 's|C:|/mnt/c|')
    if [ -f "$WSL_PATH" ]; then
      wal -i "$WSL_PATH" -q -n
    else
      echo "Wallpaper path not found or is invalid: $WSL_PATH"
    fi
  '';
in
{
  options.nyx.modules.shell.wal = {
    enable = mkEnableOption "pyWal Config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pywal
      theme_term
    ];
  };
}


