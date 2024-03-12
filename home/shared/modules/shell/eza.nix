{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.eza;
in
{
  options.nyx.modules.shell.eza = {
    enable = mkEnableOption "eza configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.eza ];
  };
}

