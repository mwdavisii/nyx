{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.glow;
in
{
  options.nyx.modules.shell.eza = {
    enable = mkEnableOption "glow configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        glow
      ];
  };
}

