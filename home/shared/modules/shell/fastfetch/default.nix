{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.fastfetch;
in
{
  options.nyx.modules.shell.fastfetch = {
    enable = mkEnableOption "fastfetch configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        fastfetch
      ];
  };
}
