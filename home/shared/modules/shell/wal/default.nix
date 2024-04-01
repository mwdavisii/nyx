{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.shell.wal;
in
{
  options.nyx.modules.shell.wal = {
    enable = mkEnableOption "pyWal Config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pywal
    ];
  };
}
