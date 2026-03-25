{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.astroterm;
in
{
  options.nyx.modules.shell.astroterm = {
    enable = mkEnableOption "astroterm terminal astronomy viewer";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.astroterm ];
  };
}
